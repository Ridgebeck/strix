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
  MissionEntry mission;
  MapEntry map;
  DataEntry data;

  AvailableAssetEntry({
    required this.entryName,
    this.call,
    required this.mission,
    required this.map,
    required this.data,
  });
}

class DataEntry {
  Map<DataType, List<DataItem>> _data = {};

  // initialize all enum data types with empty lists
  DataEntry() {
    for (DataType type in DataType.values) {
      _data[type] = const [];
    }
  }

  // create lists from dict
  dictToData({required dynamic dict}) {
    for (DataType type in DataType.values) {
      _data[type] = dict[type.name] == null
          ? const []
          : List<DataItem>.generate(
              dict[type.name].length, (index) => DataItem(fileName: dict[type.name][index]));
    }
  }

  // return list from map based on type
  List<DataItem> getData({required DataType type}) {
    return _data[type] ?? const [];
  }

  // check for new items in data entry
  bool hasNewData({required bool hasInsta}) {
    // go through all data types
    for (DataType type in DataType.values) {
      // don't check social if group has insta
      if (!(hasInsta && type == DataType.social)) {
        // check if any item is new
        if (_data[type]!.indexWhere((item) => item.isNew == true) != -1) {
          return true;
        }
      }
    }
    return false;
  }

  // check if any data is present
  bool isEmpty() {
    for (DataType type in DataType.values) {
      if (_data[type]!.isNotEmpty) {
        return false;
      }
    }
    return true;
  }
}

class DataItem {
  String fileName;
  bool isNew;

  DataItem({
    required this.fileName,
    this.isNew = false,
  });
}

class MissionEntry {
  List<Person> profileEntries;
  String? briefing;

  MissionEntry({
    this.profileEntries = const [],
    this.briefing,
  });

  bool hasNewProfiles() {
    return profileEntries.indexWhere((profile) => profile.isNew == true) == -1 ? false : true;
  }
}

class MapEntry {
  List<MarkerData> markerList;
  List<PersonMarkerData> personMarkerList;

  MapEntry({
    this.markerList = const [],
    this.personMarkerList = const [],
  });

  bool hasNewMarkers() {
    return markerList.indexWhere((marker) => marker.isNew == true) == -1 ? false : true;
  }
}
