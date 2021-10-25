import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/chat.dart';
import 'avatar.dart';
import 'text_message.dart';
import 'image_message.dart';
import 'delayed_image_message.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({
    Key? key,
    required this.fromTeam,
    required this.fromMe,
    required this.message,
    required this.delay,
  }) : super(key: key);

  final bool fromTeam;
  final bool fromMe;
  final bool delay;
  final Message message;
  final double radius = 10.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment:
            fromTeam ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          fromTeam ? Container() : Avatar(fromTeam: fromTeam, message: message),
          message.image == null
              ? TextMessage(
                  radius: radius,
                  fromMe: fromMe,
                  message: message,
                  delay: delay)
              : delay
                  ? DelayedImageMessage(
                      radius: radius,
                      fromMe: fromMe,
                      message: message,
                      delay: delay)
                  : ImageMessage(
                      radius: radius,
                      fromMe: fromMe,
                      message: message,
                      delay: delay),
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
