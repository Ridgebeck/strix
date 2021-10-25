import 'package:strix/business_logic/classes/person.dart';
import 'package:flutter/material.dart';
import 'call.dart';
import 'chat.dart';
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
  //List<Call>? archivedCalls;
  BriefingEntry? briefing;
  MissionEntry? mission;
  DataEntry? data;

  AvailableAssetEntry({
    required this.entryName,
    this.call,
    this.briefing,
    this.mission,
    this.data,
  });
}

class DataEntry {
  List<String>? social;
  List<String>? messages;
  List<String>? images;
  List<String>? audioFiles;
  List<String>? videos;
  List<String>? reports;

  int length() {
    int length = 0;
    this.social != null ? length += 1 : length = length;
    this.messages != null ? length += 1 : length = length;
    this.images != null ? length += 1 : length = length;
    this.audioFiles != null ? length += 1 : length = length;
    this.videos != null ? length += 1 : length = length;
    this.reports != null ? length += 1 : length = length;
    return length;
  }

  int categories() {
    return 5;
  }

  DataEntry({
    this.social,
    this.messages,
    this.images,
    this.audioFiles,
    this.videos,
    this.reports,
  });
}

class BriefingEntry {
  List<Person>? profileEntries;
  String? briefing;

  BriefingEntry({
    this.profileEntries,
    this.briefing,
  });
}

class MissionEntry {
  String? missionObjective;
  List<GoalAndHints>? goalList;
  //List<Person>? profileEntries; // move to briefing
  //String? briefing; // move to briefing
  List<MapPosition>? mapPositions;

  MissionEntry({
    this.missionObjective,
    this.goalList,
    //this.profileEntries,
    //this.briefing,
    this.mapPositions,
  });
}

class MapPosition {
  final double positionX;
  final double positionY;
  final bool currentGoal;
  final GlobalKey markerKey;
  final String markerText;

  MapPosition({
    required this.positionX,
    required this.positionY,
    required this.currentGoal,
    required this.markerKey,
    required this.markerText,
  });
}

class GoalAndHints {
  final String goal;
  final bool completed;
  final List<String>? hints;

  GoalAndHints({
    required this.goal,
    required this.completed,
    this.hints,
  });
}
