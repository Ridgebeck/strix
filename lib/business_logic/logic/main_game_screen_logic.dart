import 'package:strix/business_logic/classes/chat.dart';
import 'package:strix/business_logic/classes/dynamic_data.dart';
import 'package:strix/business_logic/classes/marker.dart';
import 'package:strix/business_logic/classes/static_data.dart';
import 'package:strix/config/constants.dart';
import 'package:strix/services/authorization/authorization_abstract.dart';
import 'package:strix/services/database/game_doc_abstract.dart';
import 'package:strix/services/game_state/game_state.dart';
import 'package:strix/services/service_locator.dart';

import 'map_logic.dart';

class MainGameScreenLogic {
  final GameDoc _gameDoc = serviceLocator<GameDoc>();
  final GameState _gameState = serviceLocator<GameState>();
  final Authorization _authorization = serviceLocator<Authorization>();

  // provide stream of dynamic data to UI
  Stream<DynamicData?> getDynamicDataStream({required String roomID}) {
    // TODO: check if returned data from stream makes sense
    return _gameDoc.getDataStream(roomID: roomID);
  }

  String getRoomID({required DynamicData dynamicData}) {
    // TODO: handle static data is null!
    return _gameState.staticData!.roomID;
  }

  bool userIsHost({required DynamicData dynamicData}) {
    return dynamicData.host == _authorization.getCurrentUserID();
  }

  void savePlayerData({required DynamicData dynamicData}) {
    // save user specific player object
    _gameState.userPlayerData = dynamicData.players
        .singleWhere((player) => player.uid == _authorization.getCurrentUserID());
  }

  AvailableAssetEntry getCurrentEntry({required DynamicData dynamicData}) {
    return _gameState.staticData!.availableAssets[dynamicData.gameProgressID];
  }

  void checkForNewData({
    required DynamicData dynamicData,
    required int tabIndex,
  }) {
    AvailableAssetEntry currentEntry =
        _gameState.staticData!.availableAssets[dynamicData.gameProgressID];

    // check if there are any new profiles in current asset entry
    _gameState.newData.setNewProfiles(currentEntry.mission.hasNewProfiles());

    // check if goals or hints have changed
    if (_gameState.lastGoalsAndHints != dynamicData.currentGoals) {
      if (tabIndex != kMissionTabIndex) {
        _gameState.newData.setNewGoalsOrHints(true);
      }
      _gameState.lastGoalsAndHints = dynamicData.currentGoals;
    }

    // check if there are any new markers in current asset entry
    _gameState.newData.newMapDataNotifier.value = currentEntry.map.hasNewMarkers();

    // check if there is any new data in current asset entry
    _gameState.newData.newMediaDataNotifier.value =
        currentEntry.data.hasNewData(hasInsta: dynamicData.hasInsta);
  }

  void checkForNewMessages({
    required Chat? data,
    required int tabIndex,
  }) {
    // TODO: on error, done, etc.
    // check if data is not null
    if (data != null) {
      if (data.messages.length > _gameState.totalMassages) {
        if (tabIndex != kChatTabIndex) {
          _gameState.newData.newChatDataNotifier.value = true;
        }
        _gameState.totalMassages = data.messages.length;
      }
    }
  }

  void resetGoalNotifier() {
    _gameState.newData.setNewGoalsOrHints(false);
  }

  void resetChatNotifier() {
    _gameState.newData.newChatDataNotifier.value = false;
  }

  bool hasNewCall({required DynamicData dynamicData}) {
    AvailableAssetEntry currentEntry =
        _gameState.staticData!.availableAssets[dynamicData.gameProgressID];

    if (currentEntry.call != null) {
      if (currentEntry.call != _gameState.lastCall) {
        // save current call as last call
        _gameState.lastCall = currentEntry.call;
        return true;
      }
    }
    return false;
  }

  void movePersonsOnMap({required DynamicData dynamicData}) {
    AvailableAssetEntry currentEntry =
        _gameState.staticData!.availableAssets[dynamicData.gameProgressID];

    // check for all persons with a path longer than 1 point
    List<PersonMarkerData> personsMoving = currentEntry.map.personMarkerList
        .where((element) => element.positionPath.length > 1)
        .toList();

    // check that data is present and nobody is already moving
    if (personsMoving.isNotEmpty && !_gameState.isPersonMoving) {
      // TODO: currently only using one path (first found) --> allow multiple?
      PersonMarkerData personData = personsMoving[0];

      // set moving variable to true to prevent multiple starts
      _gameState.isPersonMoving = true;
      //debugPrint("${personData.person.firstName} is moving!");

      // start calculating the move along path on map
      const MovingAnimation().createState().startMovingAnimation(
            personData: personData,
          );
    }
  }
}
