import 'package:flutter/cupertino.dart';
import 'package:strix/business_logic/classes/call.dart';
import 'package:strix/business_logic/classes/goals.dart';
import 'package:strix/business_logic/classes/new_data.dart';
import 'package:strix/business_logic/classes/player.dart';
import 'package:strix/business_logic/classes/static_data.dart';
import 'package:latlong2/latlong.dart';

// all game state variables that are needed on multiple screens
class GameState {
  // map variables and their default values
  bool isExpanded = false;
  bool showMarkerDetails = false;
  bool isPersonMoving = false;
  int markerTilePage = 998;
  double zoom = 15.0;
  LatLng centerPosition = LatLng(37.77155, -122.44866);
  State? mapState; // TODO: change to change value provider
  String maximizedDataPath = "";

  // general data
  StaticData? staticData;
  Player userPlayerData = noPlayer;

  // chat related variables
  int totalMassages = 0;
  // for delayed messages
  int displayedBotMessages = 0;
  DateTime lastTimeTyping = DateTime.utc(-271821, 04, 20);
  State? chatScreenState; // TODO: needed? or change to change value provider

  // new data variables and state of tab bar
  NewData newData = NewData();
  List<GoalAndHints> lastGoalsAndHints = [GoalAndHints(goal: "no goal yet")];
  Call? lastCall;
  State? mainScreenState; // TODO: needed? or change to change value provider
}
