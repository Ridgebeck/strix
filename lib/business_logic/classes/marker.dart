import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/person.dart';

// TODO: IMPORT MARKER COLORS AND SHAPES FROM SETTINGS
class MarkerType {
  static MarkerTypeData target = MarkerTypeData(
    typeName: 'Current Target',
    color: Colors.red,
    icon: Icons.adjust,
  );
  static MarkerTypeData store = MarkerTypeData(
    typeName: 'Store',
    color: Colors.purple,
    icon: Icons.store,
  );
  static MarkerTypeData restaurant = MarkerTypeData(
    typeName: 'Restaurant',
    color: Colors.green,
    icon: Icons.local_dining,
  );
  static MarkerTypeData poi = MarkerTypeData(
    typeName: 'Point of Interest',
    color: Colors.orange,
    icon: Icons.priority_high,
  );
  static MarkerTypeData residential = MarkerTypeData(
    typeName: 'Residential',
    color: Colors.blue,
    icon: Icons.home,
  );
  static MarkerTypeData agent = MarkerTypeData(
    typeName: 'Agent Location',
    color: Colors.blueGrey,
    icon: Icons.person,
  );
}

class MarkerTypeData {
  String typeName;
  Color color;
  IconData icon;

  MarkerTypeData({
    required this.typeName,
    required this.color,
    // default shape
    this.icon = Icons.circle,
  });
}

class MarkerData {
  String name;
  LatLng position;
  MarkerTypeData type;
  String? infoText;
  bool selected;
  bool active;
  List<Person> personsHere;

  MarkerData({
    required this.name,
    required this.position,
    required this.type,
    this.infoText,
    this.selected = false,
    this.active = true,
    this.personsHere = const [],
  });

  factory MarkerData.fromDict(dynamic markerDict) {
    return MarkerData(
      name: markerDict['name'],
      position: LatLng(markerDict['latitude'], markerDict['longitude']),
      type: markerDict['type'] == 'store'
          ? MarkerType.store
          : markerDict['type'] == 'restaurant'
              ? MarkerType.restaurant
              : markerDict['type'] == 'residential'
                  ? MarkerType.residential
                  : markerDict['type'] == 'target'
                      ? MarkerType.target
                      : MarkerType.poi,
      infoText: markerDict['infoText'],
    );
  }
}

class PersonMarkerData {
  Person person;
  List<LatLng> positionPath;
  LatLng currentPosition;
  List<LatLng>? polyPositions;
  bool atLocation;
  bool onFoot;
  String? infoText;

  PersonMarkerData({
    required this.person,
    required this.positionPath,
    required this.currentPosition,
    this.polyPositions,
    this.atLocation = false,
    this.onFoot = true,
    this.infoText,
  });

  factory PersonMarkerData.fromDict(dynamic markerDict) {
    return PersonMarkerData(
      person: Person.fromDict(markerDict['person']),
      positionPath: _createPositionPath(markerDict['latitudePath'], markerDict['longitudePath']),
      currentPosition: LatLng(markerDict['latitudePath'][0], markerDict['longitudePath'][0]),
      infoText: markerDict['infoText'],
      onFoot: markerDict['onFoot'] == 'false' ? false : true,
    );
  }
}

List<LatLng> _createPositionPath(List<dynamic> lats, List<dynamic> longs) {
  List<LatLng> path = [];

  lats.asMap().forEach((index, lat) {
    path.add(LatLng(lat, longs[index]));
  });
  return path;
}
