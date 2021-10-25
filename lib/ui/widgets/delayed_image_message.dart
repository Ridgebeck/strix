import 'dart:async';
import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/chat.dart';

class DelayedImageMessage extends StatefulWidget {
  const DelayedImageMessage({
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
  _DelayedImageMessageState createState() => _DelayedImageMessageState();
}

class _DelayedImageMessageState extends State<DelayedImageMessage> {
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
        Duration(milliseconds: 500 + 500 + widget.message.text.length * 35),
        () {
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        //boxShadow: kCardShadow,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: const Alignment(0.8, 0.0),
          colors: widget.fromMe
              ? [Colors.blueGrey[100]!, Colors.blueGrey[400]!]
              : [Colors.blueGrey[400]!, Colors.blueGrey[900]!],
        ),
      ),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.70),
      child: Column(
        children: [
          text == 'typing...'
              ? const SizedBox(width: 0.0, height: 0.0)
              : Container(
                  height: MediaQuery.of(context).size.width * 0.70,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(widget.radius)),
                    image: const DecorationImage(
                        // TODO: Change to message.image! and modify rasa response to send asset image path
                        image: AssetImage('assets/pictures/bean.gif'),
                        fit: BoxFit.cover),
                  ),
                ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              text,
              style: TextStyle(
                color: widget.fromMe ? Colors.blueGrey[900] : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
