import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/dynamic_data.dart';
import 'package:strix/business_logic/classes/static_data.dart';
import 'package:strix/business_logic/logic/mission_screen_logic.dart';
import 'package:strix/config/constants.dart';
import 'package:strix/services/game_state/game_state.dart';
import 'package:strix/services/service_locator.dart';
import 'package:strix/ui/widgets/safe_area_glas_top.dart';
import 'package:strix/ui/widgets/section_title.dart';

class GameMissionScreen extends StatelessWidget {
  final DynamicData dynamicData;

  const GameMissionScreen({
    Key? key,
    required this.dynamicData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("BUILDING MISSION SCREEN");

    final StaticData? staticData = serviceLocator<GameState>().staticData;
    MissionEntry? missionData = staticData!.availableAssets[dynamicData.gameProgressID].mission;

    // create list for profile data
    List<Widget> profileButtonList = MissionScreenLogic().createProfileList(missionData);

    // create list for converted goal data
    List<Widget> goalList = MissionScreenLogic().createGoalList(dynamicData.currentGoals);
    //missionData);

    return missionData == null
        ? const Center(
            child: Text('no mission data available yet'),
          )
        : Stack(
            children: [
              Positioned.fill(
                child: FractionallySizedBox(
                  widthFactor: 0.85,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * kSmallMargin),
                      const SectionTitle(title: 'Profiles'),
                      SizedBox(height: MediaQuery.of(context).size.height * kSmallMargin),
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
                      SizedBox(height: MediaQuery.of(context).size.height * kLargeMargin),
                      const SectionTitle(title: 'Current Objective'),
                      SizedBox(height: MediaQuery.of(context).size.height * kSmallMargin),
                      goalList.isEmpty
                          ? const Center(
                              child: Text("no current objectives"),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: goalList,
                            ),
                      SizedBox(height: MediaQuery.of(context).size.height * kLargeMargin),
                      const SectionTitle(title: 'Mission Briefing'),
                      SizedBox(height: MediaQuery.of(context).size.height * kSmallMargin),
                      missionData.briefing == null
                          ? const Center(child: Text('no briefing available'))
                          : Text(
                              missionData.briefing!.replaceAll("\\n", "\n"),
                              textAlign: TextAlign.justify,
                            ),
                      // add some buffer for end of scrolling
                      SizedBox(height: MediaQuery.of(context).size.height * kLargeMargin),
                    ],
                  ),
                ),
              ),
              const SafeAreaGlasTop(),
            ],
          );
  }
}
