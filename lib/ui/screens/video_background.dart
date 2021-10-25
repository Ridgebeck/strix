import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'landing_screen.dart';

class VideoBackground extends StatefulWidget {
  static const String routeId = 'video_background';

  const VideoBackground({Key? key}) : super(key: key);

  @override
  _VideoBackgroundState createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.asset('assets/videos/background_video.mp4')
          ..initialize().then((_) {
            // once the video has been loaded we play the video and set looping to true.
            _controller.play();
            _controller.setLooping(true);
            // ensure the first frame is shown after the video is initialized
            setState(() {});
          });
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Navigator.pushNamed(context, LandingScreen.routeId);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : Container(),
          ),
        ),
      ),
    );
  }
}
