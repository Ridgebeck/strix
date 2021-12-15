import 'dart:ui' show Color;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const String kRoomsCollection = 'activeRooms';
const String kSettingsReference = 'settings'; // used for collection name and field name
const String kDataCollection = 'data';
const String kChatCollection = 'chat';
const String kDynamicDataDoc = 'dynamicData';
const String kStaticDataDoc = 'staticData';
const String kChatDoc = 'chatData';
const String kBriefingReference = 'briefing';
const String kGoalsReference = 'goals';
const String kHintsReference = 'hints';
const String kRoomIDField = 'roomID';
const String kGameIDField = 'gameID';
const String kHostField = 'host';
const String kPlayersField = 'players';
const String kActivePlayersField = 'activePlayers';
const String kBotPersonField = 'botPersonality';
const String kGameStatusField = 'gameProgress';
const String kGameStatusIDField = 'gameProgressID';
const String kLockedForBotField = 'lockedForBot';
const String kHasInstaField = 'hasInstagram';
const String kAvailableAssetsField = 'availableAssets';
const String kOpenedField = 'opened';
const String kBotAPIAddressField = 'botAPIAddress';
const String kLockedForBot = 'lockedForBot';
const String kChatField = 'chat';
const String kChatMessagesField = 'messages';

const double kSmallMargin = 0.02;
const double kLargeMargin = 0.05;

// TODO: replace with enum?
const String kWaitingStatus = 'waiting';

// TODO: replace with selectable ID from UI (for more than one game)?
const selectedGameID = 1;

// tab indices
int kMissionTabIndex = 0;
int kMapTabIndex = 1;
int kDataTabIndex = 2;
int kChatTabIndex = 3;

const Color kBackgroundColor = Color.fromRGBO(230, 230, 235, 1.0);
const Color kBackgroundColorLight = Color.fromRGBO(238, 238, 245, 1.0);
const Color kCardColorLight = Color.fromRGBO(255, 255, 255, 1.0);
//const Color kAccentColor = Color.fromRGBO(252, 3, 173, 1.0);
const Color kAccentColor = Colors.greenAccent;
const Color kSplashColor = Color.fromRGBO(252, 3, 173, 1.0);
const Color kTextColorDark = Color.fromRGBO(60, 60, 60, 1.0);
const TextStyle kTextStyle = TextStyle(fontSize: 15, color: Colors.white);

// general glass theme values
Color kGlassColor = Colors.black.withOpacity(0.25); // cannot be const?
const double kGlassBlurriness = 15.0;
const double kGlassElevation = 0.0;

// bottom tab bar values
const Radius kBottomBarRadius = Radius.circular(15.0);
const Color kSelectedTabColor = Colors.white;
const Color kUnselectedTabColor = Colors.blueGrey;

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

enum CanLeave {
  yes,
  no,
  lastPlayer,
  error,
}

enum DataType {
  images,
  social,
  messages,
  videos,
  // audioFiles,
  // reports,
}

extension DataTypeDetails on DataType {
  String get name {
    return toString().split(".").last;
  }

  // return DataDetails as an extension to enum
  DataDetails get details {
    switch (this) {
      case DataType.images:
        return DataDetails(
          //dictKey: "images",
          title: "Images",
          folderPath: "assets/data/images/",
        );
      case DataType.social:
        return DataDetails(
          //dictKey: "social",
          title: "Social Media",
          folderPath: "assets/data/social/",
        );
      case DataType.messages:
        return DataDetails(
          //dictKey: "messages",
          title: "Messages",
          folderPath: "assets/data/messages/",
        );
      case DataType.videos:
        return DataDetails(
          //dictKey: "videos",
          title: "Videos",
          folderPath: "assets/data/videos/",
        );
    }
  }
}

class DataDetails {
  String title;
  String folderPath;

  DataDetails({
    required this.title,
    required this.folderPath,
  });
}
