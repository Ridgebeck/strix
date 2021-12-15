import 'dart:async';

import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/chat.dart';
import 'package:strix/services/game_state/game_state.dart';
import 'package:strix/services/service_locator.dart';

final GameState _gameState = serviceLocator<GameState>();

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
      print("DELAYING MESSAGE: ${widget.message.index}");
      print("DELAY TIME: ${widget.message.delayTime}");
      text = 'typing...';
    });
    _typingTimer = Timer(widget.message.delayTime, () {
      print("TIMER OVER");
      _typingTimer.cancel();
      if (widget.message.index != null) {
        print("SETTING INDEX, TIME!");
        _gameState.displayedBotMessages = widget.message.index!;
        _gameState.lastTimeTyping = DateTime.now();

        State? chatState = _gameState.chatScreenState;
        if (chatState != null) {
          if (chatState.mounted) {
            chatState.setState(() {
              print("CHAT UPDATED");
            });
          }
        }

        // TODO: SET STATE - UPDATE CHAT SCREEN
      } else {
        print("INDEX OF BOT MESSAGE WAS NULL - ERROR!");
      }
      setState(() {
        text = widget.message.text;
      });
    });
  }

  @override
  void dispose() {
    _typingTimer.cancel();
    super.dispose();
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
