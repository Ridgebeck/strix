// import 'package:flutter/material.dart';
// import 'package:strix/ui/screens/join_room_screen.dart';
// import 'package:strix/ui/screens/start_join_screen.dart';
// import 'package:strix/ui/screens/waiting_room_screen.dart';
// import 'package:video_player/video_player.dart';
// import 'package:strix/config/constants.dart';
//
// class GameSetup extends StatefulWidget {
//   static const String route_id = 'game_setup';
//
//   @override
//   _GameSetupState createState() => _GameSetupState();
// }
//
// class _GameSetupState extends State<GameSetup> {
//   VideoPlayerController _controller;
//   statusType status = statusType.landing;
//   String docID;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.asset('assets/videos/background_video.mp4')
//       ..initialize().then((_) {
//         // Once the video has been loaded we play the video and set looping to true.
//         _controller.play();
//         _controller.setLooping(true);
//         // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
//         setState(() {});
//       });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   void changeStatus(statusType value) {
//     // call set state
//     setState(() {
//       status = value;
//     });
//   }
//
//   void changeDocID(String value) {
//     docID = value;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async => false,
//       child: Scaffold(
//         body: Stack(
//           children: [
//             SizedBox.expand(
//               child: FittedBox(
//                 fit: BoxFit.cover,
//                 child: SizedBox(
//                   width: _controller.value.size?.width ?? 0,
//                   height: _controller.value.size?.height ?? 0,
//                   child: _controller.value.initialized
//                       ? AspectRatio(
//                           aspectRatio: _controller.value.aspectRatio,
//                           child: VideoPlayer(_controller),
//                         )
//                       : Container(),
//                 ),
//               ),
//             ),
//             status == statusType.landing
//                 ? StartJoinScreen(
//                     changeStatus: changeStatus,
//                     changeDocID: changeDocID,
//                   )
//                 : status == statusType.joining
//                     ? JoinRoomScreen(
//                         changeStatus: changeStatus,
//                         changeDocID: changeDocID,
//                       ) //Container(child: Center(child: Text('JOINING')))
//                     : WaitingRoomScreen(
//                         docID: docID,
//                         changeStatus: changeStatus,
//                       ),
//           ],
//         ),
//       ),
//     );
//   }
// }
