import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadFile(File file, String type) async {
    if (_auth.currentUser == null) {
      throw Exception('User not authenticated');
    }

    final userId = _auth.currentUser!.uid;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = file.path.split('.').last;
    final fileName = '$timestamp.$extension';

    try {
      // Create reference
      final storageRef = _storage.ref();
      final fileRef =
          storageRef.child('users').child(userId).child(type).child(fileName);

      print('Starting upload for $fileName');

      // Create metadata
      final metadata = SettableMetadata(
        contentType: type == 'liveness' ? 'video/mp4' : 'image/$extension',
        customMetadata: {
          'userId': userId,
          'timestamp': timestamp.toString(),
          'type': type,
        },
      );

      // Start upload
      final uploadTask = fileRef.putFile(file, metadata);

      // Monitor progress
      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          final progress =
              (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          print('Upload progress: ${progress.toStringAsFixed(2)}%');
        },
        onError: (e) => print('Upload error: $e'),
        cancelOnError: false,
      );

      // Wait for completion
      final snapshot =
          await uploadTask.whenComplete(() => print('Upload completed'));

      // Get URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('File uploaded successfully. URL: $downloadUrl');

      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Firebase error: ${e.code} - ${e.message}');
      throw Exception('Firebase upload failed: ${e.message}');
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<String> uploadDocument(File file) async {
    return uploadFile(file, 'documents');
  }

  Future<String> uploadSelfie(File file) async {
    return uploadFile(file, 'selfies');
  }

  Future<String> uploadLivenessVideo(File file) async {
    return uploadFile(file, 'liveness');
  }
}
