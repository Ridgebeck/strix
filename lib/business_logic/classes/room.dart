import 'package:strix/business_logic/classes/marker.dart';
import 'package:strix/business_logic/classes/person.dart';
import 'package:strix/config/constants.dart';
import 'call.dart';
import 'chat.dart';
import 'goals.dart';
import 'player.dart';

class Room {
  String gameTitle;
  String roomID;
  String gameProgress;
  List<Player> players;
  int minimumPlayers;
  int maximumPlayers;
  int maximumInputCharacters;
  DateTime opened;
  Chat chat;
  dynamic availableAssets;

  DateTime? started;
  String? host;

  Room({
    required this.gameTitle,
    required this.roomID,
    required this.gameProgress,
    required this.players,
    required this.minimumPlayers,
    required this.maximumPlayers,
    required this.opened,
    required this.chat,
    required this.availableAssets,
    required this.maximumInputCharacters,
    this.started,
    this.host,
  });
}

class AvailableAssetEntry {
  String entryName;
  Call? call;
  MissionEntry? mission;
  MapEntry? map;
  DataEntry? data;

  AvailableAssetEntry({
    required this.entryName,
    this.call,
    this.mission,
    this.map,
    this.data,
  });
}

class DataEntry {
  List<String>? images;
  List<String>? social;
  List<String>? messages;
  List<String>? videos;

  Map<DataType, List<String>?> toMap() {
    return {
      DataType.images: images,
      DataType.social: social,
      DataType.messages: messages,
      DataType.videos: videos,
    };
  }

  DataEntry({
    this.social,
    this.messages,
    this.images,
    this.videos,
  });
}

class MissionEntry {
  String? missionObjective;
  List<GoalAndHints> goalList;
  List<Person> profileEntries;
  String? briefing;

  MissionEntry({
    this.missionObjective,
    this.goalList = const [],
    this.profileEntries = const [],
    this.briefing,
  });
}

class MapEntry {
  List<MarkerData> markerList;
  List<PersonMarkerData> personMarkerList;

  MapEntry({
    this.markerList = const [],
    this.personMarkerList = const [],
  });
}

// class Location {
//   final String name;
//   final MarkerTypeData markerType;
//   final LatLng position;
//   final String? infoText;
//
//   Location({
//     required this.name,
//     required this.markerType,
//     required this.position,
//     this.infoText,
//   });
// }
