import 'package:flutter/material.dart';
import 'package:strix/services/database/game_doc_abstract.dart';
import '../../services/service_locator.dart';
import 'package:strix/business_logic/classes/room.dart';

// This class handles the conversion and puts it in a form convenient
// for displaying on a view (without knowing anything about any particular view).
class WaitingRoomLogic {
  final GameDoc _gameDoc = serviceLocator<GameDoc>();
  bool start = false;

  // provide stream of game room to UI
  Stream<Room?> roomDocStream(String roomID) {
    // check if returned data from stream makes sense
    print('ROOM DOC STREAM CALLED');
    return _gameDoc.getDocStream(roomID: roomID);
  }

  // try to start a game if start button is pushed
  Future<void> startGame({
    required BuildContext context,
    required int numberPlayers,
    required int minimumPlayers,
    required String roomID,
  }) async {
    // check if enough players are in room
    if (numberPlayers < minimumPlayers) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Warning'),
          content: Text('You need at least $minimumPlayers players to start the game.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        barrierDismissible: false,
      );
      // show host warning if more than 1 player is in the group
    } else if (numberPlayers > 1) {
      start = await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Warning'),
          content: Text('You become the host if you start the game. Proceed?'),
          actions: [
            TextButton(
              child: Text('BACK'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              child: Text('START'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
    // set start to true if one player starts a 1 player eligible game
    else {
      start = true;
    }

    // only start game if user clicked START
    if (start == true) {
      print('starting game...');
      bool started = await _gameDoc.startGame(roomID: roomID);
      if (started == false) {
        // todo: error handling
        print('Game could not be started');
      }
      // save player as host if start is successful (local and online?)
      // TODO: Save player as host locally?
    }
  }

  // try to leave game room if back button is pushed
  leaveRoom({
    required BuildContext context,
    required animationController,
    required String roomID,
    required int numberPlayers,
  }) async {
    bool leaving = true;
    if (numberPlayers == 1) {
      leaving = await (showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Warning'),
          content: Text('You are the last player in this room. '
              'The room will be closed so others cannot join anymore with the current code.'),
          actions: [
            TextButton(
              child: Text('BACK'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
        barrierDismissible: false,
      ));
    }
    // only try to leave if not last player or user hit okay
    if (leaving == true) {
      // remove player entry from document or
      // delete document if player is last player in room
      await _gameDoc.leaveRoom(
        roomID: roomID,
        context: context,
        animationController: animationController,
      );
    }
  }
}
