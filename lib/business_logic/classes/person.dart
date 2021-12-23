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
  bool isNew;

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
    this.isNew = false,
  });

  factory Person.fromDict(dynamic dict) {
    return Person(
      firstName: dict['firstName'],
      lastName: dict['lastName'],
      title: dict['title'],
      profileImage: dict['profileImage'],
      age: dict['age'],
      profession: dict['profession'],
      instagram: dict['instagram'],
      hobbies: dict['hobbies'],
      color: dict['color'],
    );
  }
}
