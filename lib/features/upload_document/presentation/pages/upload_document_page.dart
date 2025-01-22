import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smartkyc/core/presentation/widgets/navigation_buttons.dart';
import '../bloc/upload_document_bloc.dart';
import '../bloc/upload_document_event.dart';
import '../bloc/upload_document_state.dart';

class UploadDocumentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UploadDocumentBloc(),
      child: Scaffold(
        body: BlocConsumer<UploadDocumentBloc, UploadDocumentState>(
          listener: (context, state) {
            if (state is UploadSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text("Upload successful: ${state.file.path}")),
              );
              context.go('/selfie-start');
            } else if (state is UploadFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: ${state.error}")),
              );
            }
          },
          builder: (context, state) {
            if (state is UploadInProgress) {
              return Center(child: CircularProgressIndicator());
            }
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  "Upload Document",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                leading: IconButton(
                  icon: Icon(Icons.file_upload),
                  onPressed: () => context.go('/home'),
                ),
              ),
              body: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Image.asset(
                          "assets/images/driving_liscense_spicemen.jpg",
                        ),
                        Text(
                          "* Sample image for upload",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        Stack(
                          children: [
                            Container(
                              height: 200,
                              width: 350,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          Color.fromRGBO(205, 211, 217, 0.31))
                                ],
                                border: Border.all(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            Positioned(
                              top: 40,
                              right: 70,
                              child: ElevatedButton.icon(
                                onPressed: () => context
                                    .read<UploadDocumentBloc>()
                                    .add(PickFromGallery()),
                                icon: Icon(Icons.photo_library),
                                label: Text("Choose from Gallery"),
                              ),
                            ),
                            Positioned(
                              top: 120,
                              right: 70,
                              child: ElevatedButton.icon(
                                onPressed: () => context
                                    .read<UploadDocumentBloc>()
                                    .add(CaptureFromCamera()),
                                icon: Icon(Icons.camera_alt),
                                label: Text("Capture from Camera"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    NavigationButtons(onPrev: () {}, onNext: () {}),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
