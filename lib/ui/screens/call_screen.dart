import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/call.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';
import 'package:strix/business_logic/logic/next_milestone_logic.dart';

class CallScreen extends StatefulWidget {
  static const String routeId = 'call_screen';
  final Call call;

  const CallScreen({Key? key, required this.call}) : super(key: key);

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late VideoPlayerController _controller;
  bool closing = false;

  @override
  void initState() {
    _controller = VideoPlayerController.asset('assets/calls/${widget.call.callFile}')
      ..initialize().then((_) {
        _controller.setVolume(1.0);
        _controller.play();
        _controller.addListener(() async {
          if (_controller.value.isPlaying == false && closing == false) {
            // set variable to closing video to avoid
            // changing milestone multiple times
            closing = true;
            // TODO: Use AWAIT or close and watch the screen to change?
            NextMilestoneLogic().moveToNextMilestone();
            // pop screen when call has been finished
            Navigator.of(context).pop();
          }
        });
        // ensure the first frame is shown after the video is initialized
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    // disable wakelock again
    Wakelock.disable();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
      ),
    );
  }
}
