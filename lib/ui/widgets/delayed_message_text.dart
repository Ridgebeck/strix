import 'dart:async';

import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/chat.dart';

class DelayedMessageText extends StatefulWidget {
  const DelayedMessageText({
    Key? key,
    required this.message,
    required this.fromMe,
  }) : super(key: key);

  final Message message;
  final bool fromMe;

  @override
  _DelayedMessageTextState createState() => _DelayedMessageTextState();
}

class _DelayedMessageTextState extends State<DelayedMessageText> {
  late String text;
  late Timer _typingTimer;

  @override
  void initState() {
    super.initState();
    // TODO: Add reading delay?
    setState(() {
      text = 'typing...';
    });
    _typingTimer = Timer(
        Duration(milliseconds: 500 + widget.message.text.length * 35), () {
      setState(() {
        text = widget.message.text;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _typingTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: widget.fromMe ? Colors.blueGrey[900] : Colors.white,
      ),
    );
  }
}
