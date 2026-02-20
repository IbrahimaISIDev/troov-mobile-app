import 'package:video_player/video_player.dart';

class GlobalVideoCache {
  static final Map<String, VideoPlayerController> _controllers = {};
  static final Map<String, bool> _initialized = {};
  static final Map<String, Set<String>> _activeOwners = {}; // URLs being viewed

  static Future<VideoPlayerController> getController(String url) async {
    if (_controllers.containsKey(url)) {
      return _controllers[url]!;
    }

    final controller = VideoPlayerController.network(url);
    _controllers[url] = controller;

    // Initialize and loop
    await controller.initialize();
    await controller.setLooping(true);
    _initialized[url] = true;

    return controller;
  }

  static void play(String url, {required String ownerId}) {
    if (_controllers.containsKey(url) && _initialized[url] == true) {
      _activeOwners.putIfAbsent(url, () => {}).add(ownerId);
      _controllers[url]!.play();
    }
  }

  static void pause(String url, {required String ownerId}) {
    if (_controllers.containsKey(url)) {
      final owners = _activeOwners[url];
      if (owners != null) {
        owners.remove(ownerId);
        if (owners.isEmpty) {
          _controllers[url]!.pause();
        }
      } else {
        _controllers[url]!.pause();
      }
    }
  }

  static void dispose(String url) {
    if (_controllers.containsKey(url)) {
      _controllers[url]!.dispose();
      _controllers.remove(url);
      _initialized.remove(url);
      _activeOwners.remove(url);
    }
  }
}
