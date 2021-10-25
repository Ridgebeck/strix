import 'dart:math';
import 'package:strix/services/database/game_doc_abstract.dart';
import '../../services/service_locator.dart';

// This class handles the conversion and puts it in a form convenient
// for displaying on a view (without knowing anything about any particular view).
class StartRoomLogic {
  final GameDoc _gameDoc = serviceLocator<GameDoc>();
  //final LocalStorage _storage = serviceLocator<LocalStorage>();

  // add game to database, returns database reference
  // save reference to local memory
  Future<String?> addRoom() async {
    String? confirmedRoomID;

    // try maximum 5 times
    for (int i = 0; i < 5; i++) {
      // create new game with roomID
      confirmedRoomID = await _gameDoc.addNewRoom(roomID: _getRandomString(6));
      // exit for loop if docID is not null
      if (confirmedRoomID != null) {
        break;
      }
    }

    // save roomID to local memory
    //await _storage.saveDatabaseReference(confirmedRoomID);

    // return roomID or null
    return confirmedRoomID;
  }

  // function to create random roomID String
  String _getRandomString(int length) {
    const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    Random _rnd = Random();
    return String.fromCharCodes(
        Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }
}
