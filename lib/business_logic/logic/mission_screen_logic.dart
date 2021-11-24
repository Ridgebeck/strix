import 'package:flutter/cupertino.dart';
import 'package:strix/business_logic/classes/room.dart';
import 'package:strix/config/constants.dart';
import 'package:strix/ui/widgets/profile_button.dart';

class MissionScreenLogic {
  List<Widget> createProfileList(MissionEntry? missionData) {
    if (missionData == null) {
      return [];
    } else {
      return List.generate(
        missionData.profileEntries.length,
        (index) => ProfileButton(person: missionData.profileEntries[index]),
      );
    }
  }

  List<Widget> createGoalList(MissionEntry? missionData) {
    List<Widget> goalList = [];

    // check if mission data is null
    if (missionData != null) {
      // check if goal list is not empty (default)
      if (missionData.goalList.isNotEmpty) {
        // go through all goal entries
        for (var goalAndHints in missionData.goalList) {
          // format each active goal
          // if (goalAndHints.completed == false) {
          goalList.add(Text(
            goalAndHints.goal,
            style: const TextStyle(
              fontSize: 17.0,
              color: kAccentColor,
            ),
          ));
          goalList.add(
            const SizedBox(height: 7.0),
          );

          for (String hint in goalAndHints.hints) {
            goalList.add(
              Row(
                children: [
                  const SizedBox(width: 20.0),
                  const Text(
                    '\u2022 ',
                    style: TextStyle(
                      fontSize: 17.0,
                      color: kAccentColor,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      hint,
                      style: const TextStyle(
                        fontSize: 15.0,
                        color: kAccentColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
            // define distance between hints
            goalList.add(const SizedBox(height: 3.0));
          }
          // remove last SizedBox
          goalList.removeLast();

          // add box between active goals
          goalList.add(
            const SizedBox(height: 20.0),
          );
        }
        // remove last SizedBox (after all goals)
        goalList.removeLast();
      }
    }
    return goalList;
  }
}