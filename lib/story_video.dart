import 'dart:io';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';

/// StoryVideoState
enum StoryVideoLoadingState {
  loading,
  available;
}

class StoryVideoLoadingController extends ChangeNotifier {
  Duration _duration = Duration.zero;
  Duration get duration => _duration;

  set duration(Duration value) {
    _duration = value;
    notifyListeners();
  }

  StoryVideoLoadingState _loadingState = StoryVideoLoadingState.available;
  StoryVideoLoadingState get loadingState => _loadingState;

  set loadingState(StoryVideoLoadingState value) {
    _loadingState = value;
    notifyListeners();
  }

  StoryVideoLoadingController._();
}

final storyVideoLoadingController = StoryVideoLoadingController._();

class StoryVideo extends StatefulWidget {
  StoryVideo.network({
    Key? key,
    required this.path,
    VideoFormat? formatHint,
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
    Map<String, String> httpHeaders = const <String, String>{},
  })  : videoPlayerController = CachedVideoPlayerPlusController.networkUrl(
          Uri.parse(path),
          formatHint: formatHint,
          closedCaptionFile: closedCaptionFile,
          videoPlayerOptions: videoPlayerOptions,
          httpHeaders: httpHeaders,
        ),
        super(key: key);

  StoryVideo.file({
    Key? key,
    required this.path,
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
  })  : videoPlayerController = CachedVideoPlayerPlusController.file(
          File(path),
          closedCaptionFile: closedCaptionFile,
          videoPlayerOptions: videoPlayerOptions,
        ),
        super(key: key);

  StoryVideo.asset({
    Key? key,
    required this.path,
    String? package,
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
  })  : videoPlayerController = CachedVideoPlayerPlusController.asset(
          path,
          package: package,
          videoPlayerOptions: videoPlayerOptions,
          closedCaptionFile: closedCaptionFile,
        ),
        super(key: key);

  final String path;

  CachedVideoPlayerPlusController videoPlayerController;

  @override
  State<StoryVideo> createState() => _StoryVideoState(videoPlayerController);
}

class _StoryVideoState extends State<StoryVideo> {
  final CachedVideoPlayerPlusController _cachedVideoPlayerPlusController;

  _StoryVideoState(this._cachedVideoPlayerPlusController);

  @override
  void initState() {
    super.initState();
    storyVideoLoadingController.loadingState = StoryVideoLoadingState.loading;

    _cachedVideoPlayerPlusController.initialize().then((_) {
      setState(() {});
      storyVideoLoadingController.duration =
          _cachedVideoPlayerPlusController.value.duration;
      storyVideoLoadingController.loadingState =
          StoryVideoLoadingState.available;
      _cachedVideoPlayerPlusController.play();
    });
  }

  @override
  void dispose() {
    _cachedVideoPlayerPlusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedVideoPlayerPlusController.value.isInitialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: _cachedVideoPlayerPlusController.value.aspectRatio,
          child: CachedVideoPlayerPlus(
            _cachedVideoPlayerPlusController,
            key: widget.key,
          ),
        ),
      );
    }
    return Center(child: CircularProgressIndicator());
  }
}
