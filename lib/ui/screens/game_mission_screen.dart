import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/room.dart';
import 'package:strix/business_logic/logic/mission_screen_logic.dart';
import 'package:strix/config/constants.dart';
import 'package:strix/ui/widgets/section_title.dart';

class GameMissionScreen extends StatelessWidget {
  final MissionEntry? missionData;

  const GameMissionScreen({
    Key? key,
    required this.missionData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // create list for profile data
    List<Widget> profileButtonList = MissionScreenLogic().createProfileList(missionData);

    // create list for converted goal data
    List<Widget> goalList = MissionScreenLogic().createGoalList(missionData);

    return missionData == null
        ? const Center(
            child: Text('No mission data available yet.'),
          )
        : FractionallySizedBox(
            widthFactor: 0.85,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * smallMargin),
                const SectionTitle(title: 'Profiles'),
                SizedBox(height: MediaQuery.of(context).size.height * smallMargin),
                profileButtonList.isEmpty
                    ? const Center(
                        child: Text('no profiles available yet'),
                      )
                    : SizedBox(
                        height: MediaQuery.of(context).size.width / 6,
                        child: Center(
                          child: ListView(
                            physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics()),
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            children: profileButtonList,
                          ),
                        ),
                      ),
                SizedBox(height: MediaQuery.of(context).size.height * largeMargin),
                const SectionTitle(title: 'Current Objective'),
                SizedBox(height: MediaQuery.of(context).size.height * smallMargin),
                goalList.isEmpty
                    ? const Center(
                        child: Text("No current objectives."),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: goalList,
                      ),
                SizedBox(height: MediaQuery.of(context).size.height * largeMargin),
                const SectionTitle(title: 'Mission Briefing'),
                SizedBox(height: MediaQuery.of(context).size.height * smallMargin),
                missionData!.briefing == null
                    ? const Center(child: Text('No briefing available yet.'))
                    : Text(
                        missionData!.briefing!.replaceAll("\\n", "\n"),
                        textAlign: TextAlign.justify,
                      ),
                // add some buffer for end of scrolling
                SizedBox(height: MediaQuery.of(context).size.height * largeMargin),
              ],
            ),
          );
  }
}
