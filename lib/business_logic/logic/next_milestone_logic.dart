import 'package:strix/services/database/game_doc_abstract.dart';
import 'package:strix/services/service_locator.dart';

class NextMilestoneLogic {
  final GameDoc _gameDoc = serviceLocator<GameDoc>();
  // move to next milestone
  Future<void> moveToNextMilestone() async {
    await _gameDoc.moveToNextMilestone();
  }
}
