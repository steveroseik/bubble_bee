import 'package:audioplayers/audioplayers.dart';

class AudioProvider {
  AudioProvider() {}

  bool muted = false;

  toggleMute() {
    muted = !muted;
  }

  play(String file) async {
    if (muted) return;
    final audio = AudioPlayer();
    audio.onPlayerComplete.listen((event) {
      audio.dispose();
    });
    await audio.play(AssetSource(file));
  }
}
