import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartkyc/core/services/face_storage_service.dart';
import '../../../../core/presentation/widgets/skip_button.dart';
import '../../../../core/services/locator.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../selfie_capture/presentation/pages/selfie_start_page.dart';
import '../../../user_detail_form/presentation/pages/user_detail_form_page.dart';
import '../bloc/upload_document_bloc.dart';
import '../bloc/upload_document_event.dart';
import '../bloc/upload_document_state.dart';
import './document_camera_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class UploadDocumentPage extends StatefulWidget {
  const UploadDocumentPage({Key? key}) : super(key: key);

  static const pageName = "/uploadDocument";

  @override
  State<UploadDocumentPage> createState() => _UploadDocumentPageState();
}

class _UploadDocumentPageState extends State<UploadDocumentPage> {
  bool _isUploading = false;
  Map<String, String> userData = {};

  Future<File?> extractFaceFromDocument(File documentImage) async {
    final String apiKey = dotenv.env['API_KEY']!;
    Uri url = Uri.parse(
        "https://vision.googleapis.com/v1/images:annotate?key=$apiKey");

    // Read image as Base64
    List<int> imageBytes = await documentImage.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    // Create request payload
    var requestBody = {
      "requests": [
        {
          "image": {"content": base64Image},
          "features": [
            {"type": "FACE_DETECTION"}
          ]
        }
      ]
    };

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var faceAnnotations = jsonResponse['responses'][0]['faceAnnotations'];

        if (faceAnnotations.isNotEmpty) {
          // Extract bounding box
          var boundingBox = faceAnnotations[0]['boundingPoly']['vertices'];
          int xMin = boundingBox[0]['x'];
          int yMin = boundingBox[0]['y'];
          int xMax = boundingBox[2]['x'];
          int yMax = boundingBox[2]['y'];

          print("✅ Face Found: ($xMin, $yMin) to ($xMax, $yMax)");

          // Crop face (You need to do this in Flutter UI using Image Cropping)
          return documentImage;
        } else {
          print("❌ No face detected.");
          return null;
        }
      } else {
        print("❌ API Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error: $e");
      return null;
    }
  }

  List<List<List<List<double>>>> preprocessImage(File imageFile) {
    img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
    image = img.copyResize(image!, width: 224, height: 224);

    List<List<List<List<double>>>> input = [
      List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            var pixel = image?.getPixel(x, y);
            return [
              pixel!.r / 255.0, // Normalize Red
              pixel.g / 255.0, // Normalize Green
              pixel.b / 255.0 // Normalize Blue
            ];
          },
        ),
      )
    ]; // Wrap in a batch dimension

    print(
        "📸 Input Shape: ${input.length}x${input[0].length}x${input[0][0].length}x${input[0][0][0].length}");

    return input;
  }

  Future<bool> isNepaliLicense(File imageFile) async {
    try {
      final interpreter = await Interpreter.fromAsset(
          'assets/model/nepali_license_detector.tflite');

      // Preprocess Image
      var input = preprocessImage(imageFile);

      // Run inference
      var output = List.filled(1, 0).reshape([1, 1]);
      interpreter.run(input, output);

      double confidence = output[0][0];
      print("🔍 License Confidence Score: $confidence"); // ✅ Debugging Log

      return confidence > 0.9;
    } catch (e) {
      print("⚠️ Error running TFLite model: $e");
      return false;
    }
  }

  final FaceStorageService faceStorage = locator<FaceStorageService>();

  Future<void> _handleImageUpload(
      BuildContext context, XFile file, bool returnToProfile) async {
    setState(() {
      _isUploading = true;
    });

    try {
      print("🔍 Checking if image is a driving license...");
      File documentImage = File(file.path);
      bool isLicense = await isNepaliLicense(File(file.path));
      File? extractedFace = await extractFaceFromDocument(documentImage);
      if (extractedFace == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("No face detected in document!"),
              backgroundColor: Colors.red),
        );
        return;
      }
      faceStorage.saveExtractedFace(extractedFace);
      print("✅ Face extracted successfully: ${extractedFace.path}");
      if (!isLicense) {
        print("❌ Image is NOT a driving license!");
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Uploaded image does not look like a  driving license!'),
              backgroundColor: const Color.fromARGB(255, 14, 55, 131),
            ),
          );
        }
        setState(() {
          _isUploading = false;
        });
        return;
      }

      print("✅ Image is verified as a driving license!");
      await extractTextFromImage(file);

      if (mounted) {
        context.goNamed(
          UserDetailFormPage.pageName,
          extra: {
            'returnToProfile': returnToProfile,
            'userData': userData,
            'file': file,
          },
        );
      }
    } catch (e) {
      print('⚠️ Error uploading document: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> extractTextFromImage(XFile file) async {
    try {
      // Load Google Cloud API key from asset (or use directly)
      final String apiKey = dotenv.env['API_KEY']!;

      final File imageFile = File(file.path);
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      final Map<String, dynamic> requestBody = {
        "requests": [
          {
            "image": {"content": base64Image},
            "features": [
              {"type": "TEXT_DETECTION"} // Using OCR
            ]
          }
        ]
      };

      final Uri url = Uri.parse(
          "https://vision.googleapis.com/v1/images:annotate?key=$apiKey");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final textAnnotations =
            jsonResponse['responses'][0]['textAnnotations'] as List<dynamic>;

        if (textAnnotations.isNotEmpty) {
          final extractedText = textAnnotations[0]['description'];
          final cleantext = extractedText.replaceAll('\n', ' ').trim();
          final removednoiseText = cleantext.replaceAll(' BA ', '');

          // Extract specific details using RegExp
          parseExtractedText(removednoiseText);
        } else {
          print('No text detected in the image.');
        }
      } else {
        print('Failed to process image: ${response.body}');
      }
    } catch (e) {
      print('Error extracting text: $e');
    }
  }

  String capitalize(String name) {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  Map<String, String> parseExtractedText(String text) {
    Map<String, String> extractedData = {};

    // 1️⃣ Extract Driving License Number (Format: xx-xx-xxxxxxxx)
    RegExp licenseRegExp = RegExp(
        r'D\.L\.No\.*\s*[:]*\s*([\d]{2}-[\d]{2}-[\d]{8})',
        caseSensitive: false);
    Match? licenseMatch = licenseRegExp.firstMatch(text);
    extractedData['licenseNumber'] = licenseMatch?.group(1) ?? 'Not found';

    // 2️⃣ Extract Name and split into First Name & Last Name
    RegExp nameRegExp =
        RegExp(r'Name:\s*([A-Za-z]+)\s+([A-Za-z]+)', caseSensitive: false);
    Match? nameMatch = nameRegExp.firstMatch(text);
    String firstName = nameMatch?.group(1) ?? 'Not found';
    String lastName = nameMatch?.group(2) ?? 'Not found';

    // Apply capitalization
    extractedData['firstName'] = capitalize(firstName);
    extractedData['lastName'] = capitalize(lastName);

    // 3️⃣ Extract Date of Birth (Format: xx-xx-xxxx)
    RegExp dobRegExp = RegExp(r'D\.O\.B\.*\s*[:]*\s*([\d]{2}-[\d]{2}-[\d]{4})',
        caseSensitive: false);
    Match? dobMatch = dobRegExp.firstMatch(text);
    extractedData['dob'] = dobMatch?.group(1) ?? 'Not found';

    // 4️⃣ Extract Citizenship Number (Format: xx-xx-xx-xxxxx)
    RegExp citizenshipRegExp = RegExp(
        r'Citizenship No\.*\s*[:]*\s*([\d]{2}-[\d]{2}-[\d]{2}-[\d]{5})',
        caseSensitive: false);
    Match? citizenshipMatch = citizenshipRegExp.firstMatch(text);
    extractedData['citizenshipNumber'] =
        citizenshipMatch?.group(1) ?? 'Not found';

    // 5️⃣ Extract Father's Name (Max 3 words, ends at Last Name)
    RegExp fatherNameRegExp = RegExp(
        r'F/H Name:\s*([A-Za-z]+\s*[A-Za-z]*\s*[A-Za-z]*)\s*' + lastName,
        caseSensitive: false);
    Match? fatherNameMatch = fatherNameRegExp.firstMatch(text);
    String fatherName = fatherNameMatch != null
        ? "${fatherNameMatch.group(1)} $lastName"
        : 'Not found';

    // Apply capitalization to Father's Name
    extractedData["fatherName"] =
        fatherName.split(' ').map(capitalize).join(' ');

    // 6️⃣ Extract Address (Between "Address:" and "Nepal")
    RegExp addressRegExp = RegExp(r'Address:\s*(.*?\bNepal\b)',
        caseSensitive: false, dotAll: true);
    Match? addressMatch = addressRegExp.firstMatch(text);
    extractedData['address'] = addressMatch?.group(1)?.trim() ?? 'Not found';
    extractedData['gender'] = 'Male';

    setState(() {
      userData = extractedData;
    });

    return extractedData;
  }

  Future<void> sendImageToFastAPI(XFile file) async {
    try {
      // Convert XFile to File
      File imageFile = File(file.path);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://tesseract-ocr-1.onrender.com/upload/'),
      );
      request.files
          .add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseData);
        print('Response: $jsonResponse');
        print('Extracted Text: ${jsonResponse['extracted_text']}');
        print('Structured Data: ${jsonResponse['structured_data']}');

        // Print structured fields individually
        print(
            'License Number: ${jsonResponse['structured_data']['License Number']}');
        print('First Name: ${jsonResponse['structured_data']['First Name']}');
        print('Last Name: ${jsonResponse['structured_data']['Last Name']}');
        print(
            'Father\'s Name: ${jsonResponse['structured_data']['Father\'s Name']}');
        print(
            'Citizenship Number: ${jsonResponse['structured_data']['Citizenship Number']}');
        print('Address: ${jsonResponse['structured_data']['Address']}');
        print(
            'Date of Birth: ${jsonResponse['structured_data']['Date of Birth']}');
      } else {
        print('Failed to process image: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Background color
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));
    final l10n = AppLocalizations.of(context);
    final extraData = GoRouterState.of(context).extra;
    final bool returnToProfile = (extraData is Map<String, dynamic>)
        ? (extraData['returnToProfile'] ?? false)
        : false;

    return BlocConsumer<UploadDocumentBloc, UploadDocumentState>(
      listener: (context, state) {
        if (state is DocumentPreviewFailure) {
          final errorMessage = switch (state.error) {
            'no_image_selected' => l10n.noImageSelected,
            'camera_permission_denied' => l10n.cameraPermissionDenied,
            'failed_to_capture_image' => l10n.failedToCaptureImage,
            'invalid_image_file' => l10n.invalidImageFile,
            String msg when msg.startsWith('failed_to_pick_image') =>
              l10n.failedToPickImage + msg.substring(20),
            _ => state.error,
          };
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!returnToProfile)
                      Align(
                        alignment: Alignment.centerRight,
                        child: SkipButton(
                          onSkip: () {
                            context.go(SelfieStartPage.pageName);
                          },
                          backgroundColor:
                              isDark ? Colors.white.withOpacity(0.1) : null,
                          textColor: isDark ? Colors.white : null,
                        ),
                      ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.documentUpload,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.primary,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.documentUploadDesc,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 32),
                    if (state is DocumentPreviewInProgress)
                      Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.processingImage,
                              style: TextStyle(
                                color: isDark ? Colors.white : null,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () => _showUploadOptions(context, l10n),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[850] : Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: state is DocumentPreviewSuccess
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(state.file.path),
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Container(
                                        height: 200,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.grey[800]
                                              : Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_a_photo,
                                              size: 48,
                                              color: isDark
                                                  ? Colors.grey[500]
                                                  : Colors.grey[400],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              l10n.noDocumentSelected,
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600],
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  state is DocumentPreviewSuccess
                                      ? l10n.tapToChangeDocument
                                      : l10n.tapToUploadDocument,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    if (state is DocumentPreviewSuccess)
                      FilledButton.icon(
                        onPressed: _isUploading
                            ? null
                            : () => _handleImageUpload(
                                  context,
                                  state.file,
                                  returnToProfile,
                                ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          minimumSize: const Size(double.infinity, 56),
                        ),
                        icon: _isUploading
                            ? Container(
                                width: 24,
                                height: 24,
                                padding: const EdgeInsets.all(2),
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Icon(Icons.arrow_forward),
                        label: Text(
                          _isUploading
                              ? l10n.dataExtraction
                              : l10n.continue_operation,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.documentUploadTip,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showUploadOptions(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[850] : Colors.white,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.chooseUploadMethod,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.read<UploadDocumentBloc>().add(PickFromGallery());
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                foregroundColor: Theme.of(context).colorScheme.primary,
                elevation: 0,
                minimumSize: const Size(double.infinity, 56),
              ),
              icon: const Icon(Icons.photo_library),
              label: Text(
                l10n.chooseFromGallery,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final image = await Navigator.push<XFile>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DocumentCameraPage(),
                  ),
                );
                if (image != null && context.mounted) {
                  context
                      .read<UploadDocumentBloc>()
                      .add(SetCapturedImage(image));
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                elevation: 0,
                minimumSize: const Size(double.infinity, 56),
              ),
              icon: const Icon(Icons.camera_alt),
              label: Text(
                l10n.captureFromCamera,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
