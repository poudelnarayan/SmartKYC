import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../bloc/upload_document_bloc.dart';
import '../bloc/upload_document_event.dart';
import '../bloc/upload_document_state.dart';
import './document_camera_page.dart';

class UploadDocumentPage extends StatelessWidget {
  const UploadDocumentPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<UploadDocumentBloc, UploadDocumentState>(
      listener: (context, state) {
        if (state is UploadFailure) {
          final l10n = AppLocalizations.of(context)!;
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
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => context.go('/home'),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.documentUpload,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.documentUploadDesc,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 32),
                    if (state is UploadInProgress)
                      Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.processingImage,
                              style: Theme.of(context).textTheme.bodyLarge,
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
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: state is UploadSuccess
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
                                          color: Colors.grey[200],
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
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              l10n.noDocumentSelected,
                                              style: TextStyle(
                                                color: Colors.grey[600],
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
                                  state is UploadSuccess
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
                    if (state is UploadSuccess)
                      FilledButton.icon(
                        onPressed: () {
                          context.go('/user-detail-form');
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          minimumSize: const Size(double.infinity, 56),
                        ),
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(
                          l10n.continue_operation,
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
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.documentUploadTip,
                              style: TextStyle(
                                color: Colors.grey[600],
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
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.chooseUploadMethod,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
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
