// import 'dart:ui';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:strix/business_logic/classes/chat.dart';
// import 'package:strix/business_logic/classes/player.dart';
// import 'package:strix/business_logic/logic/chat_room_logic.dart';
// import 'package:strix/config/constants.dart';
// import 'package:strix/services/game_state/game_state.dart';
// import 'package:strix/services/service_locator.dart';
// import 'package:strix/services/authorization/authorization_abstract.dart';
// import 'package:strix/ui/widgets/chat_message.dart';
//
// const double kTextFieldHeight = 65;
// const double kTopChatAreaHeight = 80;
//
// class ChatScreenOld extends StatefulWidget {
//   const ChatScreenOld({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   State<ChatScreenOld> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreenOld> {
//   final GameState _gameState = serviceLocator<GameState>();
//   final String roomID = serviceLocator<GameState>().staticData == null
//       ? "123456"
//       : serviceLocator<GameState>().staticData!.roomID;
//   final int maxInputChar = serviceLocator<GameState>().staticData == null
//       ? 200
//       : serviceLocator<GameState>().staticData!.maximumInputCharacters;
//
//   final _textController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final Authorization _authorization = serviceLocator<Authorization>();
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     // set chat screen state so that it can be updated externally
//     _gameState.chatScreenState = this;
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//         stream: ChatRoomLogic().chatStream(roomID: roomID),
//         // TODO: use initial data instead of empty container?
//         //initialData: ,
//         builder: (BuildContext context, AsyncSnapshot<Chat?> snapshot) {
//           Chat? chatData = snapshot.data;
//           // handle chat data being null
//           if (chatData == null) {
//             if (snapshot.connectionState == ConnectionState.active) {
//               // data is null after initialization (issue)
//               // TODO: error handling? (e.g. wrong roomID)
//               debugPrint('ERROR - chat data is null');
//               return Container(color: Colors.red);
//             } else {
//               // data is null during initialization
//               return Container();
//             }
//           }
//
//           // create reduced list and delay specific bot message
//           List<Message> reducedList = ChatRoomLogic().createReducedList(chatData.messages.toList());
//
//           return Stack(
//             children: [
//               Column(
//                 children: [
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: reducedList.length, //chatData.messages.length,
//                       reverse: true,
//                       shrinkWrap: true,
//                       controller: _scrollController,
//                       physics: const BouncingScrollPhysics(),
//                       itemBuilder: (context, index) {
//                         double topPadding = 0;
//                         double bottomPadding = 0;
//                         // reverse list and save current message
//                         List<Message> reversedList = reducedList.reversed.toList();
//                         Message message = reversedList[index];
//
//                         // check if message was from current player, team member, or a bot
//                         bool fromTeam = message.author is Player;
//                         bool fromMe = fromTeam
//                             ? _authorization.getCurrentUserID() == message.author.uid
//                             : false;
//
//                         // add padding to bottom message
//                         if (index == 0) {
//                           bottomPadding = MediaQuery.of(context).padding.bottom + kTextFieldHeight;
//                         }
//                         // add padding to top message
//                         if (index == reversedList.length - 1) {
//                           topPadding = MediaQuery.of(context).padding.top + kTopChatAreaHeight;
//                         }
//
//                         if (message.delayTime != Duration()) {
//                           print(
//                               "MESSAGE WITH INDEX ${message.index} IS DELAYED BY ${message.delayTime}");
//                           print("LIST INDEX: $index");
//                           print("TEXT: ${message.text}");
//                         }
//
//                         return Padding(
//                           padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
//                           child: ChatMessage(
//                             fromTeam: fromTeam,
//                             fromMe: fromMe,
//                             message: message,
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               Positioned(
//                 top: 0.0,
//                 left: 0.0,
//                 // height: MediaQuery.of(context).padding.top + 70.0,
//                 width: MediaQuery.of(context).size.width,
//                 child: ClipRRect(
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(15.0),
//                     bottomRight: Radius.circular(15.0),
//                   ),
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(
//                       sigmaX: kGlassBlurriness,
//                       sigmaY: kGlassBlurriness,
//                     ),
//                     child: Material(
//                       color: kGlassColor,
//                       elevation: kGlassElevation,
//                       child: Column(
//                         children: [
//                           SizedBox(height: MediaQuery.of(context).padding.top),
//                           SizedBox(
//                             height: kTopChatAreaHeight,
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 15.0),
//                               child: Row(
//                                 children: [
//                                   Expanded(
//                                     flex: 2,
//                                     child: Container(),
//                                   ),
//                                   Expanded(
//                                     flex: 3,
//                                     child: Padding(
//                                       padding: const EdgeInsets.symmetric(vertical: 6.0),
//                                       child: Container(
//                                         decoration: const BoxDecoration(
//                                           image: DecorationImage(
//                                             image: AssetImage('assets/pictures/owl_v4.png'),
//                                             fit: BoxFit.contain,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     flex: 1,
//                                     child: Container(),
//                                   ),
//                                   Expanded(
//                                     flex: 10,
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Expanded(
//                                           flex: 4,
//                                           child: FittedBox(
//                                             child: chatData.botPersonality == null
//                                                 ? const Text('no receiver found')
//                                                 : Text(
//                                                     chatData.botPersonality!.title +
//                                                         ' ' +
//                                                         chatData.botPersonality!.firstName +
//                                                         ' ' +
//                                                         chatData.botPersonality!.lastName,
//                                                     style: const TextStyle(fontSize: 100.0),
//                                                   ),
//                                           ),
//                                         ),
//                                         Expanded(
//                                           flex: 1,
//                                           child: Container(),
//                                         ),
//                                         const Expanded(
//                                           flex: 3,
//                                           child: FittedBox(
//                                             child: Text(
//                                               "encrypted and secured STRIX chat",
//                                               style: TextStyle(fontSize: 100.0),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   Expanded(
//                                     flex: 3,
//                                     child: Container(),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: MediaQuery.of(context).padding.bottom - 1,
//                 left: 0.0,
//                 child: ClipRRect(
//                   borderRadius: const BorderRadius.vertical(
//                     top: kBottomBarRadius,
//                   ),
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(
//                       sigmaX: kGlassBlurriness,
//                       sigmaY: kGlassBlurriness,
//                     ),
//                     child: Material(
//                       elevation: kGlassElevation,
//                       color: Colors.transparent,
//                       child: Container(
//                         height: kTextFieldHeight,
//                         width: MediaQuery.of(context).size.width,
//                         color: kGlassColor,
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 10.0),
//                           child: Row(
//                             children: [
//                               Expanded(flex: 3, child: Container()),
//                               Expanded(
//                                 flex: 40,
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     color: Colors.blueGrey[800],
//                                     borderRadius: BorderRadius.circular(50.0),
//                                   ),
//                                   child: TextField(
//                                     cursorColor: Colors.white,
//                                     controller: _textController,
//                                     textAlignVertical: TextAlignVertical.center,
//                                     expands: true,
//                                     maxLines: null,
//                                     maxLength: maxInputChar,
//                                     maxLengthEnforcement: MaxLengthEnforcement.enforced,
//                                     decoration: const InputDecoration(
//                                       hintText: 'Type your message here...',
//                                       counterText: "", // takes too much room
//                                       contentPadding:
//                                           EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
//                                       border: InputBorder.none,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(child: Container()),
//                               TextButton(
//                                 onPressed: () {
//                                   if (_textController.text.isNotEmpty) {
//                                     ChatRoomLogic()
//                                         .addMessage(roomID: roomID, text: _textController.text);
//                                     _textController.clear();
//                                     _scrollController.animateTo(
//                                       0.0,
//                                       curve: Curves.easeOut,
//                                       duration: const Duration(milliseconds: 300),
//                                     );
//                                   }
//                                 },
//                                 child: const FittedBox(
//                                   child: FaIcon(
//                                     FontAwesomeIcons.solidPaperPlane,
//                                     color: Colors.blueGrey,
//                                     size: 25.0,
//                                   ),
//                                 ),
//                               ),
//                               Expanded(child: Container()),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         });
//   }
// }
