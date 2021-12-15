// Using an abstract class like this allows to swap concrete implementations.
// This is useful for separating architectural layers.
// It also makes testing and development easier because you can provide
// a mock implementation or fake data.
import 'package:flutter/cupertino.dart';
import 'package:strix/business_logic/classes/dynamic_data.dart';
import 'package:strix/business_logic/classes/chat.dart';

abstract class GameDoc {
  // create new game with given roomID
  // return docID of newly created game
  Future<String?> addNewRoom({required String roomID, required String mission});

  // try to join a Room via roomID
  // return docID if successful, otherwise null
  Future<String?> joinRoom({required String roomID});

  // remove player from game room
  leaveRoom({
    required String roomID,
    required BuildContext context,
    required AnimationController animationController,
  });

  Stream<DynamicData?> getDataStream({required String roomID});

  // convert doc snapshots to DynamicData class
  //DynamicData? docSnapToData({required DocumentSnapshot<Map<String, dynamic>> docSnap});

  // return stream to room document (todo: game document content)
  //Stream<Room?> getDocStream({required String roomID});

  // convert doc to Room class
  //Room? docSnapToRoom({required DocumentSnapshot<Map<String, dynamic>> docSnap});

  Stream<Chat?> getChatStream({required String roomID});

  // start game
  Future<bool> startGame({required String roomID});

  // move forward in story
  Future<void> moveToNextMilestone();

  // add message to chat room
  void addMessage({
    required Message message,
    required String roomID,
  });
}
