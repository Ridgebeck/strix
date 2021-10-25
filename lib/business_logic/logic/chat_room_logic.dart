import 'package:strix/business_logic/classes/room.dart';
import 'package:strix/business_logic/classes/chat.dart';
import 'package:strix/business_logic/classes/player.dart';
import 'package:strix/services/service_locator.dart';
import 'package:strix/services/authorization/authorization_abstract.dart';
import 'package:strix/services/database/game_doc_abstract.dart';

class ChatRoomLogic {
  final GameDoc _gameDoc = serviceLocator<GameDoc>();
  final Authorization _authorization = serviceLocator<Authorization>();

  // provide stream of game room to UI
  void addMessage({required Room room, required String text}) {
    // find player object with corresponding uid
    String uid = _authorization.getCurrentUserID();
    Player player = room.players.singleWhere((player) => player.uid == uid);

    // create message object
    Message message = Message(
      text: text,
      profileImage: null,
      image: null,
      author: player,
      time: DateTime.now(),
    );

    return _gameDoc.addMessage(roomID: room.roomID, message: message);
  }
}
