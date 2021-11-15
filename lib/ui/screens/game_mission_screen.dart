import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/person.dart';
import 'package:strix/business_logic/classes/room.dart';
import 'package:strix/config/constants.dart';
import 'package:strix/ui/screens/profile_screen.dart';

// TODO: set as standard margins in constant file or theme?
const double smallMargin = 0.020;
const double largeMargin = 0.050;

class GameMissionScreen extends StatelessWidget {
  final MissionEntry? missionData;
  const GameMissionScreen({
    Key? key,
    required this.missionData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // create list for converted goal data
    List<Widget> goalList = [];

    // check if mission data is null
    if (missionData == null) {
      // TODO: Handle case of no mission data
      print("NO MISSION DATA");
      goalList.add(Container(
        height: 50,
        color: Colors.purple,
      ));
    } else {
      // check if goal list is not null or empty
      if (missionData!.goalList != null) {
        if (missionData!.goalList!.isNotEmpty) {
          // go through all goal entries
          for (var goalAndHints in missionData!.goalList!) {
            // format each active goal
            if (goalAndHints.completed == false) {
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
              if (goalAndHints.hints != null) {
                for (String hint in goalAndHints.hints!) {
                  goalList.add(Row(
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
                  ));
                  goalList.add(const SizedBox(height: 6.0));
                }
                // remove last SizedBox
                goalList.removeLast();
              }
            }
            // format all completed goals
            else {
              goalList.add(
                SizedBox(height: MediaQuery.of(context).size.height * smallMargin),
              );
              goalList.add(
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goalAndHints.goal,
                        style: const TextStyle(
                          fontSize: 17.0,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                    const Icon(Icons.check),
                  ],
                ),
              );
            }
          }
        }
      }
    }

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
                missionData!.profileEntries == null
                    ? const Center(
                        child: Text('No profiles available yet.'),
                      )
                    : missionData!.profileEntries!.isEmpty
                        ? const Center(
                            child: Text('No profiles available yet.'),
                          )
                        : SizedBox(
                            height: MediaQuery.of(context).size.width / 6,
                            child: Center(
                              child: ListView(
                                physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics()),
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                children: List.generate(
                                  missionData!.profileEntries!.length,
                                  (index) =>
                                      ProfileButton(person: missionData!.profileEntries![index]),
                                ),
                              ),
                            ),
                          ),
                SizedBox(height: MediaQuery.of(context).size.height * largeMargin),
                const SectionTitle(title: 'Current Objective'),
                SizedBox(height: MediaQuery.of(context).size.height * smallMargin),
                Column(
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

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.033,
      child: Center(
        child: FittedBox(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 100.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileButton extends StatelessWidget {
  const ProfileButton({
    Key? key,
    required this.person,
  }) : super(key: key);

  final Person person;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50.0),
        child: Container(
          height: MediaQuery.of(context).size.width / 6,
          width: MediaQuery.of(context).size.width / 6,
          decoration: BoxDecoration(
            //color: Colors.blueGrey[100],
            borderRadius: BorderRadius.circular(150.0),
            image: DecorationImage(
              image: AssetImage(
                'assets/profile_pictures/' + person.profileImage,
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: RawMaterialButton(
            splashColor: kSplashColor,
            onPressed: () {
              Navigator.of(context).pushNamed(
                ProfileScreen.routeId,
                arguments: person,
              );
            },
          ),
        ),
      ),
    );
  }
}
