import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/chat.dart';

class MessageText extends StatelessWidget {
  const MessageText({
    Key? key,
    required this.message,
    required this.fromMe,
  }) : super(key: key);

  final Message message;
  final bool fromMe;

  @override
  Widget build(BuildContext context) {
    return Text(
      message.text,
      style: TextStyle(
        color: fromMe ? Colors.blueGrey[900] : Colors.white,
      ),
    );
  }
}
