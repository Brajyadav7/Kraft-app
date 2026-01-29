import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;
  static const String bucketName = 'sos-videos';

  /// Uploads a video file to Supabase Storage and returns the public URL
  static Future<String?> uploadVideo(File videoFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${videoFile.path.split('/').last}';
      
      debugPrint("📤 Uploading to Supabase: $fileName");

      await client.storage.from(bucketName).upload(
        fileName,
        videoFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      // Get Public URL
      final String publicUrl = client.storage.from(bucketName).getPublicUrl(fileName);
      
      debugPrint("✅ Upload Success. URL: $publicUrl");
      return publicUrl;
    } catch (e) {
      debugPrint("❌ Supabase Upload Failed: $e");
      return null;
    }
  }
}
