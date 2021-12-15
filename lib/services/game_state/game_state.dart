import 'package:flutter/cupertino.dart';
import 'package:strix/business_logic/classes/new_data.dart';
import 'package:strix/business_logic/classes/player.dart';
import 'package:strix/business_logic/classes/static_data.dart';
import 'package:latlong2/latlong.dart';

// interaction with game document on Firestore
class GameState {
  // map variables and their default values
  bool isExpanded = false;
  bool showMarkerDetails = false;
  int markerTilePage = 998;
  double zoom = 15.0;
  LatLng centerPosition = LatLng(37.77155, -122.44866);
  State? mapState;
  String maximizedDataPath = "";
  // general data
  StaticData? staticData;
  Player userPlayerData = noPlayer;
  // chat related variables
  int displayedBotMessages = 0;
  DateTime lastTimeTyping = DateTime.utc(-271821, 04, 20);
  State? chatScreenState;
  // new data variables
  NewData newData = noNewData;
}
