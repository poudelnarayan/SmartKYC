import 'dart:io';

class FaceStorageService {
  File? _extractedFace; // Store extracted face

  void saveExtractedFace(File file) {
    _extractedFace = file;
  }

  File? getExtractedFace() {
    return _extractedFace;
  }
}
