import 'package:flutter/material.dart';
import 'hex_color.dart';

class Player {
  String name;
  Color color;
  IconData iconData;
  String? uid;
  String? profileImage;

  Player({
    required this.name,
    required this.color,
    required this.iconData,
    this.uid,
    this.profileImage,
  });
  factory Player.fromDict(dynamic dict) {
    return Player(
      name: dict['name'],
      uid: dict['uid'],
      color: HexColor.fromHex(dict['color']),
      iconData: IconData(dict['iconNumber'], fontFamily: 'MaterialIcons'),
      profileImage: dict['profileImage'],
    );
  }

  static Map<String, dynamic> toDict(Player player) {
    return {
      'name': player.name,
      'uid': player.uid,
      'color': player.color.toHex(),
      'iconNumber': player.iconData.codePoint,
      'profileImage': player.profileImage,
    };
  }
}

Player noPlayer = Player(
  name: 'no player found!',
  uid: 'no uid',
  color: Colors.white,
  iconData: Icons.add,
  profileImage: null,
);
