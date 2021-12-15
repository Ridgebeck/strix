import 'dart:async';
import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/call.dart';
import 'package:strix/business_logic/classes/chat.dart';
import 'package:strix/business_logic/classes/dynamic_data.dart';
import 'package:strix/business_logic/classes/goals.dart';
import 'package:strix/business_logic/classes/hex_color.dart';
import 'package:strix/business_logic/classes/marker.dart';
import 'package:strix/business_logic/classes/player.dart';
import 'package:strix/business_logic/classes/person.dart';
import 'package:strix/business_logic/classes/static_data.dart';
import 'package:strix/services/game_state/game_state.dart';
import 'package:strix/ui/screens/briefing_screen.dart';
import 'game_doc_abstract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strix/services/service_locator.dart';
import 'package:strix/services/authorization/authorization_abstract.dart';
import 'package:strix/config/constants.dart';
//import 'package:latlong2/latlong.dart';

// interaction with room document on Firestore
class GameDocFirestore implements GameDoc {
  final Authorization _authorization = serviceLocator<Authorization>();
  final GameState _gameState = serviceLocator<GameState>();
  // Create a CollectionReference that references the firestore rooms and settings collections
  final CollectionReference<Map<String, dynamic>> rooms =
      FirebaseFirestore.instance.collection(kRoomsCollection);
  final CollectionReference<Map<String, dynamic>> settings =
      FirebaseFirestore.instance.collection(kSettingsReference);

// convert dynamic data to custom object
  DynamicData _convertDynamicData(Map<String, dynamic> dynamicData) {
    // convert player entries
    List<Player> playerList = _convertPlayerList(dynamicData[kActivePlayersField]);

    // convert current goals
    List<GoalAndHints> goalList = [];
    if (dynamicData[kGameStatusIDField] >= 0) {
      var currentGoalsEntry =
          List.from(dynamicData[kGoalsReference][dynamicData[kGameStatusIDField]]['goals']);
      if (currentGoalsEntry.isNotEmpty) {
        for (var goal in currentGoalsEntry) {
          GoalAndHints currentGoal = GoalAndHints(
            goal: goal['text'],
            hints: List.from(goal['hints'].sublist(0, goal['hintCounter'])),
          );
          goalList.add(currentGoal);
        }
      }
    }

    // create dynamic data entry
    return DynamicData(
      players: playerList,
      gameProgress: dynamicData[kGameStatusField],
      gameProgressID: dynamicData[kGameStatusIDField],
      currentGoals: goalList,
      hasInsta: dynamicData[kHasInstaField],
      host: dynamicData[kHostField],
    );
  }

  // method to convert list of dicts to list of players
  List<Player> _convertPlayerList(List<dynamic> dictList) {
    return [for (Map<String, dynamic> player in dictList) Player.fromDict(player)];
  }

  // method to convert list of players to list of dicts
  List<Map<String, dynamic>> _convertPlayerListToDict(List<Player> playerList) {
    return [for (Player player in playerList) Player.toDict(player)];
  }

// convert static data to custom object
  StaticData _convertStaticData(Map<String, dynamic> staticData) {
    return StaticData(
      availableAssets: _convertAssets(staticData[kAvailableAssetsField]),
      gameID: staticData['gameID'],
      gameTitle: staticData['gameTitle'],
      maximumInputCharacters: staticData['maximumInputCharacters'],
      maximumPlayers: staticData['maximumPlayers'],
      minimumPlayers: staticData['minimumPlayers'],
      playerData: _convertPlayerList(staticData[kPlayersField]),
      roomID: staticData['roomID'],
      opened: staticData['opened'].toDate(),
    );
  }

  // method to convert static data from firestore
  List<AvailableAssetEntry> _convertAssets(List<dynamic> assetDictList) {
    List<AvailableAssetEntry> availableAssetsFormatted = [];
    // go through all available assets
    for (Map<String, dynamic> entry in assetDictList) {
      // save asset data as map
      Map<String, dynamic> assetData = entry.values.first;

      // create empty assetEntry with only the name first
      AvailableAssetEntry assetEntry = AvailableAssetEntry(entryName: entry.keys.first);

      // check if data contains a call,convert to call object and add
      if (assetData.keys.contains('call')) {
        assetEntry.call = Call(
          callFile: assetData['call']['callFile'],
          person: Person.fromDict(assetData['call']['person']),
        );
      }

      // check if data contains a map entry,convert to map object and add
      if (assetData.keys.contains('map')) {
        assetEntry.map = MapEntry();
        // add locations markers if they exist
        if (assetData['map'].keys.contains('locations')) {
          assetEntry.map!.markerList = [
            for (Map<String, dynamic> markerDict in assetData['map']['locations'])
              MarkerData.fromDict(markerDict)
          ];
        }
        // add person locations if they exist
        // TODO: PATH CREATION IN MARKER.DART
        if (assetData['map'].keys.contains('personLocations')) {
          assetEntry.map!.personMarkerList = [
            for (Map<String, dynamic> markerDict in assetData['map']['personLocations'])
              PersonMarkerData.fromDict(markerDict)
          ];
        }
      }

      // check if data contains a mission entry,convert to mission object and add
      if (assetData.keys.contains('mission')) {
        assetEntry.mission = MissionEntry();
        // add profiles if any exists
        if (assetData['mission'].keys.contains('profiles')) {
          assetEntry.mission!.profileEntries = [
            for (Map<String, dynamic> profile in assetData['mission']['profiles'])
              Person.fromDict(profile)
          ];
        }
        // add briefing data if it exists
        if (assetData['mission'].keys.contains('briefing')) {
          assetEntry.mission!.briefing = assetData['mission']['briefing'];
        }
      }

      // check if data contains a data entry,convert to data object and add
      if (assetData.keys.contains('data')) {
        assetEntry.data = DataEntry();
        assetEntry.data!.dictToData(dict: assetData['data']);
      }
      availableAssetsFormatted.add(assetEntry);
    }

    return availableAssetsFormatted;
  }

  @override
  Future<String?> addNewRoom({required String roomID, required String mission}) async {
    // try to get document from rooms collection with random room ID
    return await rooms.doc(roomID).get().then((docSnapshot) async {
      // check if document with roomID already exists
      if (docSnapshot.exists) {
        debugPrint('Document already exists!');
        return null;
      }
      // document does not exist yet, proceed
      else {
        // fetch settings document
        DocumentSnapshot settingsSnapshot = await settings.doc(mission).get();
        // TODO: error handling

        // copy settings data as a dynamic map
        Map<String, dynamic> settingsData = settingsSnapshot.data() as Map<String, dynamic>;

        // save botPersonality, botAPI and goals and remove from settings
        Map<String, dynamic> botPersonality = settingsData[kBotPersonField];
        String botAPIAddress = settingsData[kBotAPIAddressField];
        List<dynamic> goalList = settingsData[kGoalsReference];
        settingsData.remove(kBotPersonField);
        settingsData.remove(kGoalsReference);
        settingsData.remove(kBotAPIAddressField);

        // add roomID
        settingsData[kRoomIDField] = roomID;
        // add current timestamp
        settingsData[kOpenedField] = Timestamp.fromDate(DateTime.now());

        // save static data in doc in sub collection
        await rooms.doc(roomID).collection('data').doc('staticData').set(settingsData);

        // save formatted staticData in global app memory
        _gameState.staticData = _convertStaticData(settingsData);

        // add UID to first player (host)
        Map<String, dynamic> hostData = settingsData[kPlayersField][0];
        hostData['uid'] = _authorization.getCurrentUserID();

        // initialize dynamic data with start conditions
        Map<String, dynamic> dynamicData = {
          kActivePlayersField: [hostData],
          kHasInstaField: true,
          kGameStatusField: kWaitingStatus,
          kGameStatusIDField: -1,
          kGoalsReference: goalList,
          kLockedForBot: false,
        };

        // save dynamic data document to sub collection
        await rooms.doc(roomID).collection('data').doc('dynamicData').set(dynamicData);

        // initialize chat data with start conditions
        Map<String, dynamic> chatData = {
          kBotPersonField: botPersonality,
          kChatMessagesField: [],
          kBotAPIAddressField: botAPIAddress,
          kRoomIDField: roomID,
        };

        // save chat data document to sub collection
        await rooms.doc(roomID).collection('chat').doc('chatData').set(chatData);

        // return roomID as a reference to new game room
        return roomID;
      }
    }).catchError((e) {
      debugPrint('Error while trying to create new room: $e');
      return null;
    });
  }

  @override
  Stream<DynamicData?> getDataStream({required String roomID}) {
    debugPrint('trying to start stream!');
    // Stream of Document Snapshots from database
    Stream<DocumentSnapshot<Map<String, dynamic>>> docRefStream = FirebaseFirestore.instance
        .collection(kRoomsCollection)
        .doc(roomID)
        .collection(kDataCollection)
        .doc(kDynamicDataDoc)
        .snapshots();

    // return converted stream
    return docRefStream.map((docSnap) => _docSnapToData(docSnap: docSnap));
  }

  DynamicData? _docSnapToData({required DocumentSnapshot<Map<String, dynamic>> docSnap}) {
    try {
      Map<String, dynamic>? snapData = docSnap.data();
      // check if snapshot has data
      if (!docSnap.exists || snapData == null) {
        return null;
      } else {
        debugPrint('CONVERTING DYNAMIC DATA...');
        return _convertDynamicData(snapData);
      }
    } catch (e) {
      debugPrint('Error while trying to fetch dynamic data from stream.');
      debugPrint('Error: $e');
      return null;
    }
  }

  @override
  Stream<Chat?> getChatStream({required String roomID}) {
    debugPrint('trying to start chat stream!');
    // Stream of Document Snapshots from database
    Stream<DocumentSnapshot<Map<String, dynamic>>> chatRefStream = FirebaseFirestore.instance
        .collection(kRoomsCollection)
        .doc(roomID)
        .collection(kChatCollection)
        .doc(kChatDoc)
        .snapshots();

    // return converted stream
    return chatRefStream.map((docSnap) => _docSnapToChat(docSnap: docSnap));
  }

  Chat? _docSnapToChat({required DocumentSnapshot<Map<String, dynamic>> docSnap}) {
    try {
      Map<String, dynamic>? snapData = docSnap.data();
      // check if snapshot has data
      if (!docSnap.exists || snapData == null) {
        return null;
      } else {
        // convert chat messages into standardized format
        debugPrint('CONVERTING CHAT DATA...');
        return _convertChatData(chatData: snapData);
      }
    } catch (e) {
      debugPrint('Error while trying to fetch chat from stream.');
      debugPrint('Error: $e');
      return null;
    }
  }

  Chat? _convertChatData({required Map<String, dynamic> chatData}) {
    // convert message from dict and add index
    List<Message> convertedMessages = [];
    List.from(chatData[kChatMessagesField]).asMap().forEach((index, message) {
      Message convertedMessage = Message.fromDict(message);
      convertedMessage.index = index;
      convertedMessages.add(convertedMessage);
    });

    return Chat(
      botPersonality: Person.fromDict(chatData[kBotPersonField]),
      messages: convertedMessages,
      // messages: [
      //   for (Map<String, dynamic> message in chatData[kChatMessagesField]) Message.fromDict(message)
      // ],
    );
  }

  @override
  Future<String?> joinRoom({required String roomID}) async {
    // download static data from firestore, convert and save
    StaticData staticData;
    DocumentSnapshot<Map<String, dynamic>> staticSnap =
        await (rooms.doc(roomID).collection(kDataCollection).doc(kStaticDataDoc).get());
    Map<String, dynamic>? staticSnapData = staticSnap.data();
    // check if document exists and data is not null
    if (staticSnapData == null || !staticSnap.exists) {
      return null;
    } else {
      // convert static data to custom object
      staticData = _convertStaticData(staticSnapData);
      // save staticData in global app memory
      _gameState.staticData = staticData;
    }

    // change dynamic data document safely in a transaction
    return await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document of the dynamic data
      DocumentSnapshot<Map<String, dynamic>> snapshot = await transaction.get<Map<String, dynamic>>(
          rooms.doc(roomID).collection(kDataCollection).doc(kDynamicDataDoc));
      Map<String, dynamic>? snapData = snapshot.data();

      // check if document exists and data is not null
      if (snapData == null || !snapshot.exists) {
        return null;
      } else {
        DynamicData dynamicData = _convertDynamicData(snapData);
        // check if player count is below limit
        if (dynamicData.players.length >= staticData.maximumPlayers) {
          // return error String
          return 'full';
        } else {
          // save current user ID
          String uid = _authorization.getCurrentUserID();
          // check if player (uid) is already in the room
          for (Player player in dynamicData.players) {
            if (player.uid == uid) {
              debugPrint('Player already in room. Joining.');
              return roomID;
            }
          }

          // if player is not in the room and status is waiting
          if (snapData[kGameStatusIDField] < 0) {
            // add player data and uid of current user
            dynamicData.players.add(staticData.playerData[dynamicData.players.length]);
            dynamicData.players.last.uid = uid;

            // update player list in the document
            transaction.update(rooms.doc(roomID).collection(kDataCollection).doc(kDynamicDataDoc), {
              kActivePlayersField: _convertPlayerListToDict(dynamicData.players),
            });
            return roomID;
          } else {
            return null;
          }
        }
      }
    }).then((value) {
      // return roomID if everything works out
      return value;
      // otherwise return null
    }).catchError((e) {
      debugPrint('Error while trying to join a room: $e');
      return null;
    });
  }

  @override
  leaveRoom({
    required String roomID,
    required BuildContext context,
    required AnimationController animationController,
  }) async {
    // get staticData from global app memory
    StaticData? staticSnapData = _gameState.staticData;
    // check if static data in memory is null
    if (staticSnapData == null) {
      // TODO: GET STATIC DATA FROM FIRESTORE iF MEMORY IS NULL
    }
    List<Player> playerList = List.from(staticSnapData!.playerData);

    // change dynamic data document safely in a transaction
    return await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document of the dynamic data
      DocumentSnapshot<Map<String, dynamic>> snapshot = await transaction.get<Map<String, dynamic>>(
          rooms.doc(roomID).collection(kDataCollection).doc(kDynamicDataDoc));
      Map<String, dynamic>? snapData = snapshot.data();
      // check if document exists and data is not null
      if (snapData == null || !snapshot.exists) {
        return null;
      } else {
        // get current user ID
        String uid = _authorization.getCurrentUserID();
        // get list of players
        List<Map<String, dynamic>> activePlayersList = List.from(snapData[kActivePlayersField]);

        // check if last participant is leaving
        if (activePlayersList.length == 1) {
          debugPrint('last player leaving');
          // leave page
          animationController.animateTo(0.0);
          Navigator.of(context).pushReplacementNamed(BriefingScreen.routeId);

          // delete document and sub docs after page has been left
          await Future.delayed(const Duration(seconds: 2));
          transaction.delete(rooms.doc(roomID).collection(kDataCollection).doc(kDynamicDataDoc));
          transaction.delete(rooms.doc(roomID).collection(kDataCollection).doc(kStaticDataDoc));
          transaction.delete(rooms.doc(roomID).collection(kChatCollection).doc(kChatDoc));
          await Future.delayed(const Duration(seconds: 2));
          transaction.delete(rooms.doc(roomID));

          // remove static data entry from app memory
          _gameState.staticData = null;
        }
        // if player is not last participant (host)
        else {
          debugPrint('participant leaving');
          // remove player from list
          activePlayersList.removeWhere((playerEntry) => playerEntry['uid'] == uid);
          // TODO: error handling if uid is not found?

          // keep standard player data in case order has changed
          for (int i = 0; i < activePlayersList.length; i++) {
            print(activePlayersList[i]['uid']);
            String playerUID = activePlayersList[i]['uid'];
            activePlayersList[i] = Player.toDict(playerList[i]);
            activePlayersList[i]['uid'] = playerUID;
          }
          // leave page
          animationController.animateTo(0.0);
          Navigator.of(context).pushReplacementNamed(BriefingScreen.routeId);

          // update player list in the document after page has been left
          await Future.delayed(const Duration(seconds: 2));
          transaction.update(rooms.doc(roomID).collection(kDataCollection).doc(kDynamicDataDoc), {
            kActivePlayersField: activePlayersList,
          });
        }
      }
    });
  }

  @override
  Future<bool> startGame({required String roomID}) async {
    StaticData? staticData = _gameState.staticData;
    // TODO: check if static data is null

    // change document safely in a transaction
    //todo: return value to logic?
    return await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the dynamic data document
      DocumentSnapshot<Map<String, dynamic>> snapshot = await transaction.get<Map<String, dynamic>>(
          rooms.doc(roomID).collection(kDataCollection).doc(kDynamicDataDoc));
      Map<String, dynamic>? snapshotData = snapshot.data();
      //TODO:CONVERT TO DYNAMIC DATA OBJECT

      // check if document exists and data is not null
      if (!snapshot.exists || snapshotData == null) {
        debugPrint("Error: game does not exist!");
        return false;
      } else {
        // convert to dynamic data object
        DynamicData dynamicData = _convertDynamicData(snapshotData);
        // check if game has already been started
        if (dynamicData.gameProgressID >= 0) {
          // todo: return specific value?
          return true;
        } else {
          // check if enough players are in the room
          try {
            // start game if enough players are present
            if (dynamicData.players.length >= staticData!.minimumPlayers) {
              // update room document
              transaction
                  .update(rooms.doc(roomID).collection(kDataCollection).doc(kDynamicDataDoc), {
                // save UID of host
                kHostField: _authorization.getCurrentUserID(),
                // change status to first milestone
                kGameStatusIDField: dynamicData.gameProgressID + 1,
                kGameStatusField:
                    staticData.availableAssets[dynamicData.gameProgressID + 1].entryName,
              });
            }
            return true;
          } catch (e) {
            debugPrint('No players found. Error: $e');
            return false;
          }
        }
      }
    });
  }

  @override
  Future<void> moveToNextMilestone() async {
    final StaticData? staticData = _gameState.staticData;
    // TODO: check if static data is null?
    final roomID = staticData!.roomID;

    debugPrint("MOVING TO NEXT MILESTONE");
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document
      DocumentSnapshot<Map<String, dynamic>> docSnap = await transaction.get<Map<String, dynamic>>(
          rooms.doc(roomID).collection(kDataCollection).doc(kDynamicDataDoc));
      Map<String, dynamic>? snapData = docSnap.data();
      // check if document exists and data is not null
      if (!docSnap.exists || snapData == null) {
        debugPrint("Error: game does not exist!");
      } else {
        // convert snapshot to dynamic data object
        DynamicData? dynamicData = _convertDynamicData(snapData);

        // update dynamic data document
        transaction.update(rooms.doc(roomID).collection(kDataCollection).doc(kDynamicDataDoc), {
          // change status and status ID to next milestone
          kGameStatusIDField: dynamicData.gameProgressID + 1,
          kGameStatusField: staticData.availableAssets[dynamicData.gameProgressID + 1].entryName,
          // remove the lock for bot answers
          kLockedForBotField: false,
        });
      }
    });
  }

  @override
  void addMessage({required Message message, required String roomID}) async {
    // needed to store color before converting to hex
    Color authorColor = message.author.color;

    List<dynamic> messageList = [
      {
        'text': message.text,
        'author': {
          'name': message.author.name,
          'profileImage': message.profileImage,
          'uid': message.author.uid,
          'color': authorColor.toHex(),
          'iconNumber': message.author.iconData.codePoint,
        },
        'time': DateTime.now(),
      },
    ];

    rooms
        .doc(roomID)
        .collection(kChatCollection)
        .doc(kChatDoc)
        .set({
          kChatMessagesField: FieldValue.arrayUnion(messageList),
        }, SetOptions(merge: true))
        .then((value) => debugPrint('Message added to firestore'))
        .catchError((e) => debugPrint('Error while sending message: $e'));
  }
}
