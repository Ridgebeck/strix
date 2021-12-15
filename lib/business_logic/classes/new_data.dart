import 'package:strix/config/constants.dart';

class NewData {
  bool newMissionData; // profiles, goals + hints, briefing
  bool newMapData; // markers, person markers,
  NewMediaData newMediaData;
  bool newChatData;

  NewData({
    required this.newMissionData,
    required this.newMapData,
    required this.newMediaData,
    required this.newChatData,
  });
}

NewData noNewData = NewData(
  newMissionData: false,
  newMapData: false,
  newMediaData: NewMediaData(),
  newChatData: false,
);

class NewMediaData {
  // create empty map
  Map<DataType, bool> _newData = {};

  // initialize all data types with false
  NewMediaData() {
    for (DataType type in DataType.values) {
      _newData[type] = false;
    }
  }

  // check if new data is present
  bool isThereNewData({DataType? type}) {
    // check if any value was true if no type was given
    return type == null
        ? _newData.containsValue(true)
            ? true
            : false
        // return bool for specific type
        : _newData[type] ?? false;
  }

  // set specific type to true
  setNewData({required DataType type}) {
    _newData[type] = true;
  }

  // reset all to false
  reset() {
    for (DataType type in _newData.keys) {
      _newData[type] = false;
    }
  }
}
