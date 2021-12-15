import 'package:strix/business_logic/classes/player.dart';
import 'goals.dart';

class DynamicData {
  List<Player> players;
  String gameProgress;
  int gameProgressID;
  bool hasInsta;
  List<GoalAndHints> currentGoals;
  String? host;

  DynamicData({
    required this.players,
    required this.gameProgress,
    required this.gameProgressID,
    required this.hasInsta,
    required this.currentGoals,
    this.host,
  });
}
