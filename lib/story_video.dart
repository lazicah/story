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
  State<StoryVideo> createState() => _StoryVideoState();
}

class _StoryVideoState extends State<StoryVideo> {
  @override
  void initState() {
    super.initState();
    storyVideoLoadingController.loadingState = StoryVideoLoadingState.loading;

    widget.videoPlayerController.initialize().then((_) {
      setState(() {});
      storyVideoLoadingController.duration =
          widget.videoPlayerController.value.duration;
      storyVideoLoadingController.loadingState =
          StoryVideoLoadingState.available;
      widget.videoPlayerController.play();
    });
  }

  @override
  void dispose() {
    widget.videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoPlayerController.value.isInitialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: widget.videoPlayerController.value.aspectRatio,
          child: CachedVideoPlayerPlus(
            widget.videoPlayerController,
            key: ValueKey(widget.path),
          ),
        ),
      );
    }
    return Center(child: CircularProgressIndicator());
  }
}
