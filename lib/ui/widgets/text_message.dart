import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/chat.dart';
import 'delayed_message_text.dart';
import 'message_text.dart';

class TextMessage extends StatelessWidget {
  const TextMessage({
    Key? key,
    required this.radius,
    required this.fromMe,
    required this.message,
  }) : super(key: key);

  final double radius;
  final bool fromMe;
  final Message message;

  @override
  Widget build(BuildContext context) {
    if (message.delayTime != const Duration()) {
      print("BUILDING LATEST TEXT MESSAGE ${message.index} WITH DELAY TIME: ${message.delayTime}");
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        //boxShadow: kCardShadow,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: const Alignment(0.8, 0.0),
          colors: fromMe
              ? [Colors.blueGrey[100]!, Colors.blueGrey[400]!]
              : [Colors.blueGrey[400]!, Colors.blueGrey[900]!],
        ),
      ),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.70),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: message.delayTime != const Duration()
            ? DelayedMessageText(message: message, fromMe: fromMe)
            : MessageText(message: message, fromMe: fromMe),
      ),
    );
  }
}
