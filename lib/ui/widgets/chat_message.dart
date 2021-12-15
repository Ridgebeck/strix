import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/chat.dart';
import 'avatar.dart';
import 'text_message.dart';
import 'image_message.dart';

// TODO: EXPORT TO CONSTANTS /THEME
const double radius = 10.0;

class ChatMessage extends StatelessWidget {
  const ChatMessage({
    Key? key,
    required this.fromTeam,
    required this.fromMe,
    required this.message,
  }) : super(key: key);

  final bool fromTeam;
  final bool fromMe;
  final Message message;

//   @override
//   State<ChatMessage> createState() => _ChatMessageState();
// }

// class _ChatMessageState extends State<ChatMessage> {
//   late Future<Message> _delayedMessage;

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   Duration delay = Duration();
  //   if (widget.message.delayTime != Duration()) {
  //     delay = Duration(seconds: 5);
  //   }
  //   _delayedMessage = Future<Message>.delayed(
  //     Duration(seconds: 2),
  //     //widget.message.delayTime,
  //     () => widget.message,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    if (message.delayTime != Duration()) {
      print("BUILDING LATEST CHAT MESSAGE ${message.index} WITH DELAY TIME: ${message.delayTime}");
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: fromTeam ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          fromTeam ? Container() : Avatar(fromTeam: fromTeam, message: message),
          message.image == null
              ? TextMessage(
                  radius: radius,
                  fromMe: fromMe,
                  message: message,
                )
              :
              // TODO: DELAYED IMAGE MESSAGE
              ImageMessage(radius: radius, fromMe: fromMe, message: message),
          fromTeam
              ? fromMe
                  ? Container()
                  : Avatar(fromTeam: fromTeam, message: message)
              : Container(),
        ],
      ),
    );

    // return FutureBuilder(
    //     future: _delayedMessage,
    //     builder: (BuildContext context, AsyncSnapshot<Message> snapshot) {
    //       Color colorBox;
    //       String text;
    //       if (snapshot.hasData) {
    //         colorBox = Colors.green;
    //         text = snapshot.data!.text;
    //
    //         // FormattedMessage(
    //         //   fromTeam: widget.fromTeam, fromMe: widget.fromMe, message: snapshot.data!);
    //       } else {
    //         colorBox = Colors.orange;
    //         text = "typing...";
    //       }
    //       return Row(
    //         crossAxisAlignment: CrossAxisAlignment.end,
    //         children: [
    //           Flexible(
    //             child: Container(
    //               color: colorBox,
    //               child: Text(text),
    //             ),
    //           ),
    //         ],
    //       );
    //     });
  }
}

class FormattedMessage extends StatelessWidget {
  const FormattedMessage({
    Key? key,
    required this.fromTeam,
    required this.fromMe,
    required this.message,
  }) : super(key: key);
  final bool fromTeam;
  final bool fromMe;
  final Message message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: fromTeam ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          fromTeam ? Container() : Avatar(fromTeam: fromTeam, message: message),
          message.image == null
              ? TextMessage(
                  radius: radius,
                  fromMe: fromMe,
                  message: message,
                )
              :
              // TODO: DELAYED IMAGE MESSAGE
              ImageMessage(radius: radius, fromMe: fromMe, message: message),
          fromTeam
              ? fromMe
                  ? Container()
                  : Avatar(fromTeam: fromTeam, message: message)
              : Container(),
        ],
      ),
    );
  }
}
