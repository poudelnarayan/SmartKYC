import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/skip_button.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../selfie_capture/presentation/pages/selfie_start_page.dart';
import '../../../user_detail_form/presentation/pages/user_detail_form_page.dart';
import '../bloc/upload_document_bloc.dart';
import '../bloc/upload_document_event.dart';
import '../bloc/upload_document_state.dart';
import './document_camera_page.dart';

class UploadDocumentPage extends StatefulWidget {
  const UploadDocumentPage({Key? key}) : super(key: key);

  static const pageName = "/uploadDocument";

  @override
  State<UploadDocumentPage> createState() => _UploadDocumentPageState();
}

class _UploadDocumentPageState extends State<UploadDocumentPage> {
  bool _isUploading = false;

  Future<void> _handleImageUpload(
      BuildContext context, XFile file, Object? extradata) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final storageService = StorageService();
      final downloadUrl = await storageService.uploadDocument(File(file.path));
      print('Document uploaded successfully: $downloadUrl');

      if (mounted) {
        context.goNamed(
          UserDetailFormPage.pageName,
          extra: extradata,
        );
      }
    } catch (e) {
      print('Error uploading document: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final extraData = GoRouterState.of(context).extra;
    final bool returnToProfile = (extraData is Map<String, dynamic>)
        ? (extraData['returnToProfile'] ?? false)
        : false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                                  extraData,
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
