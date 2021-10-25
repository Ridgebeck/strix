import 'package:flutter/material.dart';

class Person {
  String firstName;
  String lastName;
  String title;
  String profileImage;
  int? age;
  String? profession;
  String? instagram;
  String? hobbies;
  Color? color;

  Person({
    required this.firstName,
    required this.lastName,
    required this.title,
    required this.profileImage,
    this.age,
    this.profession,
    this.instagram,
    this.hobbies,
    this.color,
  });
}
