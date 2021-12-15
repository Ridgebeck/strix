import 'dart:math';

import 'package:strix/business_logic/classes/person.dart';
import 'package:strix/business_logic/classes/chat.dart';
import 'package:strix/business_logic/classes/player.dart';
import 'package:strix/services/game_state/game_state.dart';
import 'package:strix/services/service_locator.dart';
//import 'package:strix/services/authorization/authorization_abstract.dart';
import 'package:strix/services/database/game_doc_abstract.dart';

class ChatRoomLogic {
  final GameDoc _gameDoc = serviceLocator<GameDoc>();
  final GameState _gameState = serviceLocator<GameState>();
  //final Authorization _authorization = serviceLocator<Authorization>();

  // provide stream of chat data to UI
  Stream<Chat?> chatStream({required String roomID}) {
    return _gameDoc.getChatStream(roomID: roomID);
  }

  // provide stream of game room to UI
  void addMessage({required String roomID, required String text}) {
    // create message object with current user as player
    Message message = Message(
      text: text,
      profileImage: null,
      image: null,
      author: _gameState.userPlayerData, //getUserPlayerData(),
      time: DateTime.now(),
    );

    return _gameDoc.addMessage(roomID: roomID, message: message);
  }

  List<Message> createReducedList(List<Message> messagesList) {
    // get index of message to delay and add delay to message object
    //int delayedMessageIdx = _getDelayedMessageIdx(messagesList);

    int delayedMessageIdx = -1;
    print("delayedMessageIdx: $delayedMessageIdx");

    List<Message> reducedList = [];
    // just return everything if there is no new message
    if (delayedMessageIdx == -1) {
      return messagesList;
    }
    // if there is a message to delay
    // create truncated sublist without additional bot messages
    messagesList.asMap().forEach((idx, message) {
      // add all player messages + bot messages up to current index
      if (message.author.runtimeType == Player || idx <= delayedMessageIdx) {
        reducedList.add(message);
      }
    });
    return reducedList;
  }

  int _getDelayedMessageIdx(List<Message> messagesList) {
    print("LAST DISPLAYED BOT MESSAGE IDX: ${_gameState.displayedBotMessages}");

    // check if already displayed message is not last message in list
    if (_gameState.displayedBotMessages >= messagesList.length - 1) {
      return -1;
    }

    messagesList[_gameState.displayedBotMessages].delayTime = const Duration();

    // set to -2 by default
    int nextBotMessageIdx = -2;
    // set index to -1 by default (no message to delay)
    int delayedMessageIdx = -1;

    // go through bot messages until there are no more of them
    while (nextBotMessageIdx != -1) {
      // start from message after last displayed message
      int listStart = min(_gameState.displayedBotMessages + 1, messagesList.length);
      // look for next bot message
      // returns -1 if nothing was found (e.g. only player messages, end of list)
      nextBotMessageIdx =
          messagesList.sublist(listStart).indexWhere((m) => m.author.runtimeType == Person);

      // if there was another bot message
      if (nextBotMessageIdx > -1) {
        // add list start to have correct index for whole list
        nextBotMessageIdx += listStart;
        // calculate smallest waiting time delta
        Duration waitingTimeDelta = _getWaitingTimeDelta(messagesList[nextBotMessageIdx]);
        // calculate time for typing based on message length
        Duration timeTyping =
            Duration(milliseconds: 2000 + 40 * messagesList[nextBotMessageIdx].text.length);
        print("timeTyping: $timeTyping");

        // check if message was received while bot was "typing"
        if (waitingTimeDelta < timeTyping) {
          // calculate remaining typing delay time and save in message
          messagesList[nextBotMessageIdx].delayTime = timeTyping - waitingTimeDelta;
          // save index of message to delay
          delayedMessageIdx = nextBotMessageIdx;
          // exit while loop
          break;
        }
        // otherwise set message to displayed and reset duration
        _gameState.displayedBotMessages = nextBotMessageIdx;
      }
    }
    return delayedMessageIdx;
  }

  Duration _getWaitingTimeDelta(Message message) {
    // get time since last question and last bot message
    Duration timeSinceAsked = message.timeAsked == null
        ? const Duration(seconds: 5)
        : DateTime.now().difference(message.timeAsked!);
    // get time since last answer (after typing was finished)
    Duration timeSinceLastAnswer = DateTime.now().difference(_gameState.lastTimeTyping);
    //print("timeSinceAsked: $timeSinceAsked");
    //print("timeSinceLastAnswer: $timeSinceLastAnswer");

    // find minim of two durations and return
    int comparisonInt = timeSinceAsked.compareTo(timeSinceLastAnswer);
    return comparisonInt < 0 ? timeSinceAsked : timeSinceLastAnswer;
  }
}
