import 'dart:async';

//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/call.dart';
import 'package:strix/business_logic/classes/chat.dart';
import 'package:strix/business_logic/classes/hex_color.dart';
import 'package:strix/business_logic/classes/room.dart';
import 'package:strix/business_logic/classes/player.dart';
import 'package:strix/business_logic/classes/person.dart';
import 'package:strix/ui/screens/briefing_screen.dart';
import 'game_doc_abstract.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strix/services/service_locator.dart';
import 'package:strix/services/authorization/authorization_abstract.dart';
import 'package:strix/config/constants.dart';

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
        print('Document already exists!');
        return null;
      }
      // document does not exist yet, proceed
      else {
        // try to fetch settings document
        // TODO: replace mission1 with (selectable) gameID
        DocumentSnapshot settingsSnapshot =
            await settings.doc('mission1').get();

        // create first player entry
        Map<String, dynamic> firstPlayerValues =
            settingsSnapshot[kPlayersField][0];
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
      print('Error while trying to create new room: $e');
      return null;
    });
  }

  @override
  Stream<Room?> getDocStream({required String roomID}) {
    print('trying to start stream!');
    // Stream of Document Snapshots from database
    Stream<DocumentSnapshot<Map<String, dynamic>>> docRefStream =
        FirebaseFirestore.instance
            .collection(kRoomsCollection)
            .doc(roomID)
            .snapshots();

    // return converted string
    return docRefStream.map((docSnap) => docSnapToRoom(docSnap: docSnap));
  }

  @override
  Room? docSnapToRoom(
      {required DocumentSnapshot<Map<String, dynamic>> docSnap}) {
    try {
      Map<String, dynamic>? snapData = docSnap.data();
      // check if snapshot has data
      if (!docSnap.exists || snapData == null) {
        return null;
      } else {
        print('CONVERTING STREAM DATA! ${snapData['gameID']}');

        // convert player list into standardized format
        List<Player> playerList = [];
        for (int i = 0; i < snapData[kPlayersField].length; i++) {
          Map<String, dynamic> currentPlayer = snapData[kPlayersField][i];

          playerList.add(
            Player(
              uid: currentPlayer['uid'],
              name: currentPlayer['name'],
              color: HexColor.fromHex(currentPlayer['color']),
              iconData: IconData(currentPlayer['iconNumber'],
                  fontFamily: 'MaterialIcons'),
              profileImage: currentPlayer['profileImage'],
            ),
          );
        }

        // convert chat messages into standardized format
        Chat chat = _convertChatData(
            chatData: snapData[kChatField],
            protagonists: snapData[kSettingsReference]['protagonists']);

        // convert available assets into standardized format
        print('convert assets');
        List<AvailableAssetEntry> availableAssets =
            _convertAvailableAssets(snapData);

        print('create room from stream');
        // convert all values into room class
        Room currentRoomData = Room(
          gameTitle: snapData[kSettingsReference]['gameTitle'],
          roomID: snapData[kRoomIDField],
          gameProgress: snapData[kGameStatusField],
          players: playerList,
          minimumPlayers: snapData[kSettingsReference]['minimumPlayers'],
          maximumPlayers: snapData[kSettingsReference]['maximumPlayers'],
          maximumInputCharacters: snapData[kSettingsReference]
              ['maximumInputCharacters'],
          opened: snapData['opened'].toDate(),
          chat: chat,
          started: snapData['started'],
          availableAssets:
              availableAssets, //snapData[kSettingsReference][kSettingsStatusField],
          host: snapData['host'],
        );
        return currentRoomData;
      }
    } catch (e) {
      print('Error while trying to create room data from stream.');
      print('Error: $e');
      return null;
    }
  }

  List<AvailableAssetEntry> _convertAvailableAssets(
      Map<String, dynamic> snapData) {
    List<AvailableAssetEntry> availableAssets = [];
    List<dynamic> availableAssetsRaw =
        snapData[kSettingsReference][kSettingsStatusField];
    late AvailableAssetEntry assetEntry;

    print('CONVERTING ASSETS');

    // go through all entries in list
    for (Map<String, dynamic> milestone in availableAssetsRaw) {
      milestone.forEach((name, value) {
        // save entry name
        assetEntry = AvailableAssetEntry(entryName: name);

        // go through each entry in milestone
        value.forEach((assetEntryField, fieldData) {
          // convert call if there is one
          if (assetEntryField == 'call') {
            Map<String, dynamic> callMap =
                snapData[kSettingsReference]['calls'][value['call']];
            Map<String, dynamic> callerMap =
                snapData[kSettingsReference]['protagonists'][callMap['person']];
            Person caller = Person(
              firstName: callerMap['firstName'],
              lastName: callerMap['lastName'],
              profileImage: callerMap['profileImage'],
              title: callerMap['title'],
              age: callerMap['age'],
              profession: callerMap['profession'],
              instagram: callerMap['instagram'],
            );
            Call currentCall = Call(
              callFile: callMap['callFile'],
              person: caller,
            );
            assetEntry.call = currentCall;
            print('CALL CONVERTED');
          }
          // convert data entry
          else if (assetEntryField == 'data') {
            print('Found data entry');
            assetEntry.data = DataEntry();
            // go through data entry
            fieldData.forEach((dataField, dataFieldData) {
              if (dataField == 'social' &&
                  snapData[kSettingsReference]['hasInstagram'] == false) {
                print('Found social entry and group does not have insta');
                assetEntry.data!.social = List.from(dataFieldData);
              }
              if (dataField == 'messages') {
                print('Found messages entry');
                assetEntry.data!.messages = List.from(dataFieldData);
              }
              if (dataField == 'pictures') {
                print('Found pictures entry');
                assetEntry.data!.images = List.from(dataFieldData);
              }
              if (dataField == 'audioFiles') {
                print('Found audioFiles entry');
                assetEntry.data!.audioFiles = List.from(dataFieldData);
              }
              if (dataField == 'videos') {
                print('Found videos entry');
                assetEntry.data!.videos = List.from(dataFieldData);
              }
              if (dataField == 'reports') {
                print('Found reports entry');
                assetEntry.data!.reports = List.from(dataFieldData);
              }
            });
          }

          // convert briefing entry
          else if (assetEntryField == 'briefing') {
            print('Found briefing entry');
            assetEntry.briefing = BriefingEntry();
            // add briefing to mission entry
            assetEntry.briefing!.briefing =
                snapData[kSettingsReference][kBriefingReference];

            // go through all fields of briefing entry
            fieldData.forEach((briefingField, briefingFieldData) {
              // add profiles of people
              if (briefingField == 'profiles' &&
                  List.from(briefingFieldData).isNotEmpty) {
                print('Found profiles entry');

                List<Person> profiles = [];
                // go through all profiles
                briefingFieldData.forEach((profileName) {
                  print(snapData[kSettingsReference]['protagonists']
                      [profileName]['firstName']);

                  // create person from reference string
                  Person currentPerson = Person(
                    firstName: snapData[kSettingsReference]['protagonists']
                        [profileName]['firstName'],
                    lastName: snapData[kSettingsReference]['protagonists']
                        [profileName]['lastName'],
                    title: snapData[kSettingsReference]['protagonists']
                        [profileName]['title'],
                    profileImage: snapData[kSettingsReference]['protagonists']
                        [profileName]['profileImage'],
                    age: snapData[kSettingsReference]['protagonists']
                        [profileName]['age'],
                    profession: snapData[kSettingsReference]['protagonists']
                        [profileName]['profession'],
                    hobbies: snapData[kSettingsReference]['protagonists']
                        [profileName]['hobbies'],
                    instagram: snapData[kSettingsReference]['protagonists']
                        [profileName]['instagram'],
                  );

                  profiles.add(currentPerson);
                });
                assetEntry.briefing!.profileEntries = profiles;
                print("all profiles converted");
              }
            });
          }

          // convert mission entry
          else if (assetEntryField == 'mission') {
            print('Found mission entry');
            assetEntry.mission = MissionEntry();

            int activeGoal = 0;
            int? completedGoal;

            // find active goal and completed goal numbers
            fieldData.forEach((missionField, missionFieldData) {
              if (missionField == 'activeGoal') {
                print('active goal found!');
                activeGoal = missionFieldData;
              }
              if (missionField == 'completedGoal') {
                print('completed goal found!');
                completedGoal = missionFieldData;
              }
            });

            // define empty lists to add room data in correct format
            List<GoalAndHints> goalAndHintList = [];
            List<MapPosition> mapPositionList = [];

            // convert array from Firestore to dynamic list
            List<dynamic> firestoreGoalsList =
                List.from(snapData[kSettingsReference][kGoalsReference]);

            bool currentMapPoint = true;

            // convert each list entry from Firestore into correct format
            for (var i = activeGoal; i >= 0; i--) {
              print('converting goal');
              goalAndHintList.add(
                GoalAndHints(
                  goal: firestoreGoalsList[i]['text'],
                  completed: completedGoal == null
                      ? false
                      : i <= completedGoal!
                          ? true
                          : false,
                  hints: List.from(
                    snapData[kSettingsReference][kHintsReference]['goal$i'] ??
                        [],
                  ),
                ),
              );

              if (firestoreGoalsList[i].containsKey('mapPoint')) {
                mapPositionList.add(
                  MapPosition(
                    markerKey: GlobalKey(),
                    markerText: firestoreGoalsList[i]['mapPoint']['name'],
                    positionX: firestoreGoalsList[i]['mapPoint']['positionX']
                        .toDouble(),
                    positionY: firestoreGoalsList[i]['mapPoint']['positionY']
                        .toDouble(),
                    currentGoal: currentMapPoint,
                  ),
                );
                currentMapPoint = false;
              }
            }

            // add converted lists to mission section of asset entry
            assetEntry.mission!.goalList = goalAndHintList;
            assetEntry.mission!.mapPositions = mapPositionList;
          }
          // convert all other entries
          else {
            print("Room conversion warning - Unknown entry found!");
          }
        });
      });
      print('adding assetEntry ${assetEntry.entryName}');
      availableAssets.add(assetEntry);
    }
    return availableAssets;
  }

  Chat _convertChatData(
      {Map<String, dynamic>? chatData, Map<String, dynamic>? protagonists}) {
    List<Message> chatList = [];
    print('CONVERTING CHAT');

    if (chatData == null) {
      print('no chat data to convert');
    } else {
      print('messages: ${chatData[kChatMessagesField].length}');

      for (int i = 0; i < chatData[kChatMessagesField].length; i++) {
        try {
          Map<String, dynamic> currentMessage = chatData[kChatMessagesField][i];
          Map<String, dynamic> currentAuthor = currentMessage['author'];

          Person? currentPerson;
          Player? currentPlayer;

          if (currentAuthor.containsKey('uid')) {
            print('Author has UID --> Human!');
          }

          // check if author is player or person
          if (currentAuthor.containsKey('uid')) {
            print('Player Message');
            currentPlayer = Player(
              name: currentAuthor['name'],
              uid: currentAuthor['uid'],
              color: HexColor.fromHex(currentAuthor['color']),
              iconData: IconData(currentAuthor['iconNumber'],
                  fontFamily: 'MaterialIcons'),
            );
          } else {
            print('Person Message');

            String authorName = currentAuthor['botPersonality'];

            if (protagonists == null) {
              print('Error - Protagonist section not found!');
            } else {
              if (protagonists[authorName] == null) {
                print('Error - Protagonist $authorName could not be found!');
              } else {
                Map<String, dynamic> authorEntry = protagonists[authorName];

                currentPerson = Person(
                  firstName: authorEntry['firstName'],
                  lastName: authorEntry['lastName'],
                  title: authorEntry['title'],
                  profileImage: authorEntry['profileImage'],
                  age: authorEntry['age'],
                  profession: authorEntry['profession'],
                  hobbies: authorEntry['hobbies'],
                  instagram: authorEntry['instagram'],
                  color: HexColor.fromHex(authorEntry['color']),
                );
              }
            }
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
          print('Could not convert message. Error: $e');
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

        print('PLAYER LIST: $playersList');
        print('UID: ${_authorization.getCurrentUserID()}');

        if (playersList.length >= snapData['settings']['maximumPlayers']) {
          // return error String
          return 'full';
        } else {
          // get current user ID
          String uid = _authorization.getCurrentUserID();

          // check if player (uid) is already in the room
          for (Map<String, dynamic> playerEntry in playersList) {
            if (playerEntry['uid'] == uid) {
              print('Player already in room. Joining.');
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
      print('Error while trying to join a room: $e');
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
        print("Error: game does not exist or has no data!");
        // todo: error handling?
      }
      // check if game has already been started
      else if (snapData[kGameStatusField] != kWaitingStatus) {
        print("Game has been started already!");
      }
      // otherwise leave the room
      else {
        // get current user ID
        String uid = _authorization.getCurrentUserID();
        // get list of players
        List<Map<String, dynamic>> playersList = List.from(snapData['players']);

        // check if last participant is leaving
        if (playersList.length == 1) {
          print('last player leaving');
          // leave page
          animationController.animateTo(0.0);
          Navigator.of(context).pushReplacementNamed(BriefingScreen.routeId);

          // delete complete document after page has been left
          await Future.delayed(const Duration(seconds: 3));
          // todo: delete after leaving room
          transaction.delete(rooms.doc(roomID));
        } else {
          print('participant leaving');
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
        print("Error: game does not exist!");
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
              kGameStatusField:
                  snapData['settings'][kSettingsStatusField][0].keys.first,
            });
          }
          return true;
        } catch (e) {
          print('No players found. Error: $e');
          return false;
        }
      }
    });
  }

  @override
  Future<void> moveToNextMilestone({required String roomID}) async {
    print("MOVING TO NEXT MILESTONE");
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document
      DocumentSnapshot<Map<String, dynamic>> docSnap =
          await transaction.get<Map<String, dynamic>>(rooms.doc(roomID));
      Map<String, dynamic>? snapData = docSnap.data();
      // check if document exists and data is not null
      if (!docSnap.exists || snapData == null) {
        print("Error: game does not exist!");
      } else {
        // convert snapshot to Room class
        Room? room = docSnapToRoom(docSnap: docSnap);
        // check if room data is not null
        if (room == null) {
          print("Room data is null");
        } else {
          // find index of current milestone
          // find current progress entry
          AvailableAssetEntry currentEntry = room.availableAssets
              .singleWhere((element) => element.entryName == room.gameProgress);

          int currentIndex = room.availableAssets.indexOf(currentEntry);
          print('INDEX: $currentIndex');

          // update room document
          transaction.update(rooms.doc(roomID), {
            // change status to next milestone
            kGameStatusField: snapData['settings'][kSettingsStatusField]
                    [currentIndex + 1]
                .keys
                .first,
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
        .then((value) => print('Updated'))
        .catchError((e) => print('Error while sending message: $e'));

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
