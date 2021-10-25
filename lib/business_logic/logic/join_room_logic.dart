import 'package:flutter/material.dart';
import 'package:strix/services/database/game_doc_abstract.dart';
import 'package:strix/services/service_locator.dart';
import 'package:strix/ui/screens/waiting_room_screen.dart';

// This class handles the conversion and puts it in a form convenient
// for displaying on a view (without knowing anything about any particular view).
class JoinRoomLogic {
  final GameDoc _gameDoc = serviceLocator<GameDoc>();
  //final LocalStorage _storage = serviceLocator<LocalStorage>();

  // add game to database, returns database reference
  // save reference to local memory
  Future<void> joinRoom({
    required BuildContext context,
    required String roomID,
    required AnimationController animationController,
  }) async {
    String? docID = await _gameDoc.joinRoom(roomID: roomID);
    // display error or join room
    if (docID == 'full') {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Warning'),
          content: const Text('Could not join room. Room was already full.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } else if (docID == null) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Warning'),
          content: const Text('Could not join room. Room ID was not found.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } else {
      animationController.animateTo(0.0);
      // navigate to waiting room
      Navigator.of(context)
          .pushReplacementNamed(WaitingRoomScreen.routeId, arguments: docID);
    }
  }
}
