import 'package:strix/business_logic/classes/person.dart';
import 'package:strix/business_logic/classes/player.dart';
import 'package:strix/config/constants.dart';
import 'call.dart';
import 'marker.dart';

class StaticData {
  List<AvailableAssetEntry> availableAssets;
  int gameID;
  String gameTitle;
  int maximumInputCharacters;
  int maximumPlayers;
  int minimumPlayers;
  List<Player> playerData;
  String roomID;
  DateTime? opened;
  DateTime? started;

  StaticData({
    required this.availableAssets,
    required this.gameID,
    required this.gameTitle,
    required this.maximumInputCharacters,
    required this.maximumPlayers,
    required this.minimumPlayers,
    required this.playerData,
    required this.roomID,
    this.opened,
    this.started,
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
  Map<DataType, List<String>> _data = {};

  // initialize all enum data types with empty lists
  DataEntry() {
    for (DataType type in DataType.values) {
      _data[type] = const [];
    }
  }

  // create lists from dict
  dictToData({required dynamic dict}) {
    for (DataType type in DataType.values) {
      _data[type] = dict[type.name] == null ? const [] : List.from(dict[type.name]);
    }
  }

  // return list from map based on type
  List<String> getData({required DataType type}) {
    return _data[type] ?? const [];
  }
}

class MissionEntry {
  List<Person> profileEntries;
  String? briefing;

  MissionEntry({
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
