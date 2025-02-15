// import 'dart:io';
// import 'package:flutter_ffmpeg_lts/flutter_ffmpeg.dart';
// import 'package:path_provider/path_provider.dart';

// final FlutterFFmpeg _ffmpeg = FlutterFFmpeg();

// /// ✅ Trim and Compress Video
// Future<File?> trimAndCompressVideo(File videoFile) async {
//   try {
//     final Directory tempDir = await getTemporaryDirectory();
//     final String outputPath = "${tempDir.path}/trimmed_compressed_video.mp4";

//     // ✅ FFmpeg command: Trim first 5 seconds & lower quality
//     String command =
//         "-i ${videoFile.path} -t 5 -vf scale=640:360 -b:v 500k -preset ultrafast -c:a copy $outputPath";

//     int rc = await _ffmpeg.execute(command);
//     if (rc == 0) {
//       print("✅ Video trimmed & compressed: $outputPath");
//       return File(outputPath);
//     } else {
//       print("❌ FFmpeg failed!");
//       return null;
//     }
//   } catch (e) {
//     print("❌ Video Processing Error: $e");
//     return null;
//   }
// }
