import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/chat.dart';
import 'message_text.dart';

class ImageMessage extends StatelessWidget {
  const ImageMessage({
    Key? key,
    required this.radius,
    required this.fromMe,
    required this.message,
    required this.delay,
  }) : super(key: key);

  final double radius;
  final bool fromMe;
  final Message message;
  final bool delay;

  @override
  Widget build(BuildContext context) {
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
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.70),
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.width * 0.70,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
              image: const DecorationImage(
                  // TODO: Change to message.image! and modify rasa response to send asset image path
                  image: AssetImage('assets/pictures/bean.gif'),
                  fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: MessageText(message: message, fromMe: fromMe),
          ),
        ],
      ),
    );
  }
}
