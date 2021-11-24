import 'dart:async';

//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/call.dart';
import 'package:strix/business_logic/classes/chat.dart';
import 'package:strix/business_logic/classes/hex_color.dart';
import 'package:strix/business_logic/classes/marker.dart';
import 'package:strix/business_logic/classes/room.dart';
import 'package:strix/business_logic/classes/player.dart';
import 'package:strix/business_logic/classes/person.dart';
import 'package:strix/ui/screens/briefing_screen.dart';
import 'game_doc_abstract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strix/services/service_locator.dart';
import 'package:strix/services/authorization/authorization_abstract.dart';
import 'package:strix/config/constants.dart';
import 'package:latlong2/latlong.dart';

// interaction with room document on Firestore
class GameDocFirestore implements GameDoc {
  final Authorization _authorization = serviceLocator<Authorization>();
  // Create a CollectionReference that references the firestore rooms and settings collections
  final CollectionReference<Map<String, dynamic>> rooms =
      FirebaseFirestore.instance.collection(kRoomsCollection);
  final CollectionReference<Map<String, dynamic>> settings =
      FirebaseFirestore.instance.collection(kSettingsReference);

  @override
  Future<String?> addNewRoom({required String roomID}) async {
    // try to get document from rooms collection with random room ID
    return await rooms.doc(roomID).get().then((docSnapshot) async {
      // check if document with roomID already exists
      if (docSnapshot.exists) {
        debugPrint('Document already exists!');
        return null;
      }
      // document does not exist yet, proceed
      else {
        // try to fetch settings document
        // TODO: replace mission1 with (selectable) gameID
        DocumentSnapshot settingsSnapshot = await settings.doc('mission1').get();

        // create first player entry
        Map<String, dynamic> firstPlayerValues = settingsSnapshot[kPlayersField][0];
        Map<String, dynamic> playerEntry = {
          'uid': _authorization.getCurrentUserID(),
          'name': firstPlayerValues['name'],
          'isHuman': firstPlayerValues['isHuman'],
          'iconNumber': firstPlayerValues['iconNumber'],
          'color': firstPlayerValues['color'],
        };

        // try to create document with roomID
        await rooms.doc(roomID).set({
          kRoomIDField: roomID,
          kGameIDField: settingsSnapshot.get(kGameIDField),
          kOpenedField: DateTime.now(),
          kPlayersField: [playerEntry],
          kGameStatusField: kWaitingStatus,
          kSettingsReference: settingsSnapshot.data(),
          kChatField: {'messages': []},
        });
        return roomID;
      }
    }).catchError((e) {
      debugPrint('Error while trying to create new room: $e');
      return null;
    });
  }

  @override
  Stream<Room?> getDocStream({required String roomID}) {
    debugPrint('trying to start stream!');
    // Stream of Document Snapshots from database
    Stream<DocumentSnapshot<Map<String, dynamic>>> docRefStream =
        FirebaseFirestore.instance.collection(kRoomsCollection).doc(roomID).snapshots();

    // return converted string
    return docRefStream.map((docSnap) => docSnapToRoom(docSnap: docSnap));
  }

  @override
  Room? docSnapToRoom({required DocumentSnapshot<Map<String, dynamic>> docSnap}) {
    try {
      Map<String, dynamic>? snapData = docSnap.data();
      // check if snapshot has data
      if (!docSnap.exists || snapData == null) {
        return null;
      } else {
        debugPrint('CONVERTING STREAM DATA! ${snapData['gameID']}');

        // convert player list into standardized format
        List<Player> playerList = [];
        for (int i = 0; i < snapData[kPlayersField].length; i++) {
          Map<String, dynamic> currentPlayer = snapData[kPlayersField][i];

          playerList.add(
            Player(
              uid: currentPlayer['uid'],
              name: currentPlayer['name'],
              color: HexColor.fromHex(currentPlayer['color']),
              iconData: IconData(currentPlayer['iconNumber'], fontFamily: 'MaterialIcons'),
              profileImage: currentPlayer['profileImage'],
            ),
          );
        }

        // convert chat messages into standardized format
        Chat chat = _convertChatData(
            chatData: snapData[kChatField],
            protagonists: snapData[kSettingsReference]['protagonists']);

        // convert available assets into standardized format
        debugPrint('convert assets');
        List<AvailableAssetEntry> availableAssets = _convertAvailableAssets(snapData);

        debugPrint('create room from stream');
        // convert all values into room class
        Room currentRoomData = Room(
          gameTitle: snapData[kSettingsReference]['gameTitle'],
          roomID: snapData[kRoomIDField],
          gameProgress: snapData[kGameStatusField],
          players: playerList,
          minimumPlayers: snapData[kSettingsReference]['minimumPlayers'],
          maximumPlayers: snapData[kSettingsReference]['maximumPlayers'],
          maximumInputCharacters: snapData[kSettingsReference]['maximumInputCharacters'],
          opened: snapData['opened'].toDate(),
          chat: chat,
          started: snapData['started'],
          availableAssets: availableAssets, //snapData[kSettingsReference][kSettingsStatusField],
          host: snapData['host'],
        );
        return currentRoomData;
      }
    } catch (e) {
      debugPrint('Error while trying to create room data from stream.');
      debugPrint('Error: $e');
      return null;
    }
  }

  List<AvailableAssetEntry> _convertAvailableAssets(Map<String, dynamic> snapData) {
    List<AvailableAssetEntry> availableAssets = [];
    List<dynamic> availableAssetsRaw = snapData[kSettingsReference][kSettingsStatusField];
    late AvailableAssetEntry assetEntry;

    debugPrint('CONVERTING ASSETS');

    // go through all entries in list
    for (Map<String, dynamic> milestone in availableAssetsRaw) {
      milestone.forEach((name, value) {
        // save entry name
        assetEntry = AvailableAssetEntry(entryName: name);

        // go through each entry in milestone
        value.forEach((assetEntryField, fieldData) {
          // convert call if there is one
          if (assetEntryField == 'call') {
            assetEntry.call = Call(
              callFile: fieldData['callFile'],
              person: Person(
                firstName: fieldData['person']['firstName'],
                lastName: fieldData['person']['lastName'],
                profileImage: fieldData['person']['profileImage'],
                title: fieldData['person']['title'],
                age: fieldData['person']['age'],
                profession: fieldData['person']['profession'],
                instagram: fieldData['person']['instagram'],
              ),
            );

            debugPrint('CALL CONVERTED');
          }
          // convert data entry
          else if (assetEntryField == 'data') {
            debugPrint('Found data entry');
            assetEntry.data = DataEntry();
            // go through data entry
            fieldData.forEach((dataField, dataFieldData) {
              if (dataField == 'social' && snapData[kSettingsReference]['hasInstagram'] == false) {
                debugPrint('Found social entry and group does not have insta');
                assetEntry.data!.social = List.from(dataFieldData);
              }
              if (dataField == 'messages') {
                debugPrint('Found messages entry');
                assetEntry.data!.messages = List.from(dataFieldData);
              }
              if (dataField == 'pictures') {
                debugPrint('Found pictures entry');
                assetEntry.data!.images = List.from(dataFieldData);
              }
              if (dataField == 'videos') {
                debugPrint('Found videos entry');
                assetEntry.data!.videos = List.from(dataFieldData);
              }
            });
          }

          // convert mission entry
          else if (assetEntryField == 'mission') {
            debugPrint('Found mission entry');
            // create empty mission entry
            assetEntry.mission = MissionEntry();

            // find active goal and completed goal numbers
            fieldData.forEach(
              (missionField, missionFieldData) {
                // convert current goals
                if (missionField == 'currentGoals') {
                  // define empty list to add goal data in correct format
                  List<GoalAndHints> goalAndHintList = [];

                  // add each goal to list
                  for (var goal in missionFieldData) {
                    goalAndHintList.add(
                      GoalAndHints(
                        goal: goal['text'],
                        hints: goal['hints'].cast<String>(),
                      ),
                    );
                  }
                  assetEntry.mission!.goalList = goalAndHintList;
                }

                // convert profiles
                if (missionField == 'profiles') {
                  // define empty lists to add profile entries in correct format
                  List<Person> profileEntries = [];

                  // go through profile list
                  missionFieldData.forEach((profile) {
                    // convert all profile entries (maps/dicts) into person class
                    profile.forEach((profileName, profileValues) {
                      Person currentProfile = Person(
                        firstName: profileValues['firstName'],
                        lastName: profileValues['lastName'],
                        title: profileValues['title'],
                        profession: profileValues['profession'],
                        age: profileValues['age'],
                        profileImage: profileValues['profileImage'],
                        instagram: profileValues['instagram'],
                        hobbies: profileValues['hobbies'],
                      );
                      // add profile to list
                      profileEntries.add(currentProfile);
                    });
                  });

                  // add converted lists to mission section of asset entry
                  assetEntry.mission!.profileEntries = profileEntries;
                  debugPrint('All profiles converted!');
                }
                // add briefing to mission data
                if (missionField == 'briefing') {
                  assetEntry.mission!.briefing = missionFieldData;
                }
              },
            );
          }

          // convert map entry
          else if (assetEntryField == 'map') {
            debugPrint('Found map entry');
            // create empty mission entry
            assetEntry.map = MapEntry();
            // create empty marker lists
            List<MarkerData> markerList = [];
            List<PersonMarkerData> personMarkerList = [];

            // go through all map data
            fieldData.forEach((mapField, mapFieldData) {
              // find location data
              if (mapField == 'locations') {
                mapFieldData.forEach((location) {
                  markerList.add(
                    MarkerData(
                      name: location['name'],
                      type: location['type'] == 'store'
                          ? MarkerType.store
                          : location['type'] == 'restaurant'
                              ? MarkerType.restaurant
                              : location['type'] == 'residential'
                                  ? MarkerType.residential
                                  : location['type'] == 'target'
                                      ? MarkerType.target
                                      : MarkerType.poi,
                      position: LatLng(location['latitude'], location['longitude']),
                      infoText: location['infoText'],
                    ),
                  );
                });
              }

              // find personLocation data
              if (mapField == 'personLocations') {
                debugPrint("person location data found!");
                mapFieldData.forEach((location) {
                  // convert path into LatLng format list
                  List<LatLng> positionPath = [];
                  location['latitudePath'].asMap().forEach((index, latitude) {
                    positionPath.add(LatLng(latitude, location['longitudePath'][index]));
                  });

                  personMarkerList.add(PersonMarkerData(
                    person: Person(
                      firstName: location['person']['firstName'],
                      lastName: location['person']['lastName'],
                      title: location['person']['title'],
                      profession: location['person']['profession'],
                      age: location['person']['age'],
                      profileImage: location['person']['profileImage'],
                      hobbies: location['person']['hobbies'],
                      instagram: location['person']['instagram'],
                    ),
                    positionPath: positionPath,
                    currentPosition: positionPath[0],
                    onFoot: location['onFoot'] ?? false,
                    infoText: location['infoText'],
                  ));
                });
              }
            });
            // add converted locations to map section of asset entry
            assetEntry.map!.markerList = markerList;
            assetEntry.map!.personMarkerList = personMarkerList;
            debugPrint('All locations converted!');
          }

          // convert all other entries
          else {
            debugPrint("Room conversion warning - Unknown entry found!");
            // TODO: Handle unknown entries
          }
        });
      });
      debugPrint('adding assetEntry ${assetEntry.entryName}');
      availableAssets.add(assetEntry);
    }
    return availableAssets;
  }

  Chat _convertChatData({Map<String, dynamic>? chatData, Map<String, dynamic>? protagonists}) {
    List<Message> chatList = [];
    debugPrint('CONVERTING CHAT');

    if (chatData == null) {
      debugPrint('no chat data to convert');
    } else {
      debugPrint('messages: ${chatData[kChatMessagesField].length}');

      for (int i = 0; i < chatData[kChatMessagesField].length; i++) {
        try {
          Map<String, dynamic> currentMessage = chatData[kChatMessagesField][i];
          Map<String, dynamic> currentAuthor = currentMessage['author'];

          Person? currentPerson;
          Player? currentPlayer;

          if (currentAuthor.containsKey('uid')) {
            debugPrint('Author has UID --> Human!');
          }

          // check if author is player or person
          if (currentAuthor.containsKey('uid')) {
            debugPrint('Player Message');
            currentPlayer = Player(
              name: currentAuthor['name'],
              uid: currentAuthor['uid'],
              color: HexColor.fromHex(currentAuthor['color']),
              iconData: IconData(currentAuthor['iconNumber'], fontFamily: 'MaterialIcons'),
            );
          } else {
            debugPrint('Bot Message');

            currentPerson = Person(
              firstName: currentAuthor['firstName'],
              lastName: currentAuthor['lastName'],
              title: currentAuthor['title'],
              profileImage: currentAuthor['profileImage'],
              age: currentAuthor['age'],
              profession: currentAuthor['profession'],
              hobbies: currentAuthor['hobbies'],
              instagram: currentAuthor['instagram'],
              //color: HexColor.fromHex(currentAuthor['color']),
            );
          }

          chatList.add(
            Message(
              text: currentMessage['text'],
              profileImage: currentMessage['profileImage'],
              image: currentMessage['image'],
              author: currentPlayer ?? currentPerson,
              time: currentMessage['time'].toDate(),
            ),
          );
        } catch (e) {
          debugPrint('Could not convert message. Error: $e');
        }
      }
    }
    return Chat(messages: chatList);
  }

  @override
  Future<String?> joinRoom({required String roomID}) async {
    // change document safely in a transaction
    return await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await transaction.get<Map<String, dynamic>>(rooms.doc(roomID));
      Map<String, dynamic>? snapData = snapshot.data();
      // check if document exists and data is not null
      if (snapData == null || !snapshot.exists) {
        return null;
      } else {
        // check if player count is below limit
        List<Map<String, dynamic>> playersList = List.from(snapData['players']);

        debugPrint('PLAYER LIST: $playersList');
        debugPrint('UID: ${_authorization.getCurrentUserID()}');

        if (playersList.length >= snapData['settings']['maximumPlayers']) {
          // return error String
          return 'full';
        } else {
          // get current user ID
          String uid = _authorization.getCurrentUserID();

          // check if player (uid) is already in the room
          for (Map<String, dynamic> playerEntry in playersList) {
            if (playerEntry['uid'] == uid) {
              debugPrint('Player already in room. Joining.');
              return roomID;
            }
          }

          // if player is not in the room and status is waiting
          if (snapData[kGameStatusField] == kWaitingStatus) {
            // find corresponding player data
            Map<String, dynamic> playerData =
                snapData[kSettingsReference][kPlayersField][playersList.length];

            // add new player with uid and copied player data
            Map<String, dynamic> playerEntry = {
              'uid': uid,
              'name': playerData['name'],
              'iconNumber': playerData['iconNumber'],
              'color': playerData['color'],
            };
            playersList.add(playerEntry);

            // update player list on the document
            transaction.update(rooms.doc(roomID), {
              'players': playersList,
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
    // change document safely in a transaction
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await transaction.get<Map<String, dynamic>>(rooms.doc(roomID));
      Map<String, dynamic>? snapData = snapshot.data();

      // check if document exists
      if (!snapshot.exists || snapData == null) {
        debugPrint("Error: game does not exist or has no data!");
        // todo: error handling?
      }
      // check if game has already been started
      else if (snapData[kGameStatusField] != kWaitingStatus) {
        debugPrint("Game has been started already!");
      }
      // otherwise leave the room
      else {
        // get current user ID
        String uid = _authorization.getCurrentUserID();
        // get list of players
        List<Map<String, dynamic>> playersList = List.from(snapData['players']);

        // check if last participant is leaving
        if (playersList.length == 1) {
          debugPrint('last player leaving');
          // leave page
          animationController.animateTo(0.0);
          Navigator.of(context).pushReplacementNamed(BriefingScreen.routeId);

          // delete complete document after page has been left
          await Future.delayed(const Duration(seconds: 3));
          // todo: delete after leaving room
          transaction.delete(rooms.doc(roomID));
        } else {
          debugPrint('participant leaving');
          // remove player from list
          playersList.removeWhere((playerEntry) => playerEntry['uid'] == uid);
          // TODO: error handling if uid is not found?

          // update other player data in case the order changed
          List<Map<String, dynamic>> playerDataList =
              List.from(snapData[kSettingsReference][kPlayersField]);

          for (int i = 0; i < playersList.length; i++) {
            playersList[i] = {
              'uid': playersList[i]['uid'],
              'name': playerDataList[i]['name'],
              'iconNumber': playerDataList[i]['iconNumber'],
              'color': playerDataList[i]['color'],
            };
          }
          // leave page
          animationController.animateTo(0.0);
          Navigator.of(context).pushReplacementNamed(BriefingScreen.routeId);

          // perform an update on the document after page has been left
          await Future.delayed(const Duration(seconds: 2));
          transaction.update(rooms.doc(roomID), {
            'players': playersList,
          });
        }
      }
    });
  }

  @override
  Future<bool> startGame({required String roomID}) async {
    // change document safely in a transaction
    //todo: return value to logic?
    return await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await transaction.get<Map<String, dynamic>>(rooms.doc(roomID));
      Map<String, dynamic>? snapData = snapshot.data();

      // check if document exists and data is not null
      if (!snapshot.exists || snapData == null) {
        debugPrint("Error: game does not exist!");
        return false;
      }
      // check if game has already been started
      else if (snapData[kGameStatusField] != kWaitingStatus) {
        // todo: return specific value?
        return true;
      } else {
        // check if enough players are in the room
        try {
          int numberPlayers = snapData['players'].length;
          int minimumPlayers = snapData['settings']['minimumPlayers'];

          // start game if enough players are present
          if (numberPlayers >= minimumPlayers) {
            // update room document
            transaction.update(rooms.doc(roomID), {
              // save UID of host
              kHostField: _authorization.getCurrentUserID(),
              // change status to first milestone
              kGameStatusField: snapData['settings'][kSettingsStatusField][0].keys.first,
            });
          }
          return true;
        } catch (e) {
          debugPrint('No players found. Error: $e');
          return false;
        }
      }
    });
  }

  @override
  Future<void> moveToNextMilestone({required String roomID}) async {
    debugPrint("MOVING TO NEXT MILESTONE");
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document
      DocumentSnapshot<Map<String, dynamic>> docSnap =
          await transaction.get<Map<String, dynamic>>(rooms.doc(roomID));
      Map<String, dynamic>? snapData = docSnap.data();
      // check if document exists and data is not null
      if (!docSnap.exists || snapData == null) {
        debugPrint("Error: game does not exist!");
      } else {
        // convert snapshot to Room class
        Room? room = docSnapToRoom(docSnap: docSnap);
        // check if room data is not null
        if (room == null) {
          debugPrint("Room data is null");
        } else {
          // find current progress entry
          AvailableAssetEntry currentEntry =
              room.availableAssets.singleWhere((element) => element.entryName == room.gameProgress);
          // find index of current milestone
          int currentIndex = room.availableAssets.indexOf(currentEntry);

          // TODO: make sure that milestone is only changed by one player at a time
          // don't allow changes to milestones in time window?
          // update room document
          transaction.update(rooms.doc(roomID), {
            // change status to next milestone
            kGameStatusField:
                snapData['settings'][kSettingsStatusField][currentIndex + 1].keys.first,
          });
        }
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
        .set({
          'chat': {'messages': FieldValue.arrayUnion(messageList)},
        }, SetOptions(merge: true))
        .then((value) => debugPrint('Updated'))
        .catchError((e) => debugPrint('Error while sending message: $e'));

    // rooms
    //     .doc(roomID)
    //     .collection('messages')
    //     .doc()
    //     .set({
    //       'text': message.text,
    //       'author': {
    //         'name': message.author.name,
    //         'uid': message.author.uid,
    //         'color': authorColor.toHex(),
    //         'iconNumber': message.author.iconData.codePoint,
    //       },
    //       'time': DateTime.now(),
    //       'roomID': roomID,
    //     }, SetOptions(merge: true))
    //     .then((value) => print('Updated'))
    //     .catchError((e) => print('Error while sending message: $e'));
  }
}
