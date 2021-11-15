import 'dart:ui';
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
  String infoText;
  bool selected;
  bool agentIsHere;
  bool active;
  Person? person;

  MarkerData({
    required this.name,
    required this.position,
    required this.type,
    this.infoText = "",
    this.selected = false,
    this.agentIsHere = false,
    this.active = true,
    this.person,
  });
}
