import 'package:audioplayers/audioplayers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_player_service.g.dart';

// Sound fx - onboarding zoom sound, clicking buttons, clicking lottie buttons
// action verified success/fail, toasts, marketplace success/fail
class AudioPlayerService {
  AudioPlayerService() {
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playSound(String asset, {String extension = 'wav'}) async {
    try {
      await _audioPlayer.play(AssetSource('sounds/$asset.$extension'));
    } catch (e) {
      // debugPrint(e.toString());
    }
  }

  Future<void> playClickSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/Abstract2.wav'));
    } catch (e) {
      // debugPrint(e.toString());
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
  }
}

@Riverpod(keepAlive: true)
AudioPlayerService audioPlayerService(AudioPlayerServiceRef ref) =>
    AudioPlayerService();
