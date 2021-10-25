import 'package:flutter/material.dart';

class Player {
  String name;
  String uid;
  Color color;
  IconData iconData;
  String? profileImage;

  Player({
    required this.name,
    required this.uid,
    required this.color,
    required this.iconData,
    this.profileImage,
  });
}

Player noPlayer = Player(
  name: 'no player found!',
  uid: 'no uid',
  color: Colors.white,
  iconData: Icons.add,
  profileImage: null,
);
