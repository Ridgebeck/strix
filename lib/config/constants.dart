import 'dart:ui' show Color;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const String kRoomsCollection = 'activeRooms';
const String kSettingsReference = 'settings'; // used for collection name and field name
const String kBriefingReference = 'briefing';
const String kGoalsReference = 'goals';
const String kHintsReference = 'hints';
const String kRoomIDField = 'roomID';
const String kGameIDField = 'gameID';
const String kHostField = 'host';
const String kPlayersField = 'players';
const String kGameStatusField = 'gameProgress';
const String kSettingsStatusField = 'availableAssets'; // change to gameProgress
const String kOpenedField = 'opened';
const String kChatField = 'chat';
const String kChatMessagesField = 'messages';

const double smallMargin = 0.02;
const double largeMargin = 0.05;

// TODO: replace with enum?
const String kWaitingStatus = 'waiting';

// TODO: replace with selectable ID from UI (for more than one game)?
const selectedGameID = 1;

const Color kBackgroundColor = Color.fromRGBO(230, 230, 235, 1.0);
const Color kBackgroundColorLight = Color.fromRGBO(238, 238, 245, 1.0);
const Color kCardColorLight = Color.fromRGBO(255, 255, 255, 1.0);
//const Color kAccentColor = Color.fromRGBO(252, 3, 173, 1.0);
const Color kAccentColor = Colors.greenAccent;
const Color kSplashColor = Color.fromRGBO(252, 3, 173, 1.0);
const Color kTextColorDark = Color.fromRGBO(60, 60, 60, 1.0);
const TextStyle kTextStyle = TextStyle(fontSize: 15, color: Colors.white);

const List<BoxShadow> kCardShadow = [
  BoxShadow(
    color: Colors.blueGrey,
    blurRadius: 3.0,
    spreadRadius: 1.0,
    offset: Offset(0.5, 0.5),
  ),
  BoxShadow(
    color: Colors.white,
    blurRadius: 3.0,
    spreadRadius: 1.0,
    offset: Offset(-0.5, -0.5),
  ),
];

enum canLeave {
  yes,
  no,
  lastPlayer,
  error,
}

enum dataType {
  images,
  social,
  messages,
  videos,
  audioFiles,
  reports,
}

class DataCategory {
  // TODO: static or static const?
  static DataDetails images = DataDetails(
    type: dataType.images,
    title: "Images",
    folderPath: "assets/data/images/",
  );
  static DataDetails social = DataDetails(
    type: dataType.social,
    title: "Social Media",
    folderPath: "assets/data/social/",
  );
  static DataDetails messages = DataDetails(
    type: dataType.messages,
    title: "Messages",
    folderPath: "assets/data/messages/",
  );
  static DataDetails videos = DataDetails(
    type: dataType.videos,
    title: "Videos",
    folderPath: "assets/data/videos/",
  );
}

class DataDetails {
  dataType type;
  String title;
  String folderPath;

  DataDetails({
    required this.type,
    required this.title,
    required this.folderPath,
  });
}
