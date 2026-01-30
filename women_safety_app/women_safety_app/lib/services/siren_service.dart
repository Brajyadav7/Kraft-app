import 'package:audioplayers/audioplayers.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:flutter/foundation.dart';

class SirenService {
  static final AudioPlayer _player = AudioPlayer();
  static bool isPlaying = false;
  static double _previousVolume = 0.5;

  /// Toggles the siren on/off
  static Future<void> toggleSiren() async {
    if (isPlaying) {
      await stopSiren();
    } else {
      await playSiren();
    }
  }

  /// Plays the siren at max volume
  static Future<void> playSiren() async {
    try {
      // Save current volume to restore later
      _previousVolume = await VolumeController().getVolume();
      
      // Set Request: Max Volume
      VolumeController().setVolume(1.0);
      
      // Set source and loop (Reverting to local asset as folder issue is fixed)
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setSource(AssetSource('sounds/police_siren.mp3'));
      await _player.resume();
      
      isPlaying = true;
      debugPrint("🚨 Siren STARTED at Max Volume");
    } catch (e) {
      debugPrint("❌ Error playing siren: $e");
    }
  }

  /// Stops the siren and restores volume
  static Future<void> stopSiren() async {
    try {
      await _player.stop();
      // Restore previous volume (optional, usually good UX)
      VolumeController().setVolume(_previousVolume);
      
      isPlaying = false;
      debugPrint("🚨 Siren STOPPED");
    } catch (e) {
      debugPrint("❌ Error stopping siren: $e");
    }
  }
}
