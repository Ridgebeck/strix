import 'package:flutter/cupertino.dart';

class NewData {
  // value notifiers to build bottom tab bar with indicator
  final newMissionDataNotifier = ValueNotifier<bool>(false);
  final newMapDataNotifier = ValueNotifier<bool>(false);
  final newMediaDataNotifier = ValueNotifier<bool>(false);
  final newChatDataNotifier = ValueNotifier<bool>(false);

  bool newProfiles;
  bool newGoalsOrHints;

  NewData({
    this.newProfiles = false,
    this.newGoalsOrHints = false,
  });

  void setNewProfiles(bool hasNewProfiles) {
    newProfiles = hasNewProfiles;
    newMissionDataNotifier.value = newProfiles || newGoalsOrHints;
  }

  void setNewGoalsOrHints(bool hasNewGoals) {
    newGoalsOrHints = hasNewGoals;
    newMissionDataNotifier.value = newProfiles || newGoalsOrHints;
  }
}
