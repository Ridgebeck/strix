import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/person.dart';
import 'package:strix/business_logic/classes/room.dart';
import 'package:strix/config/constants.dart';
import 'package:strix/ui/screens/profile_screen.dart';

class GameBriefingScreen extends StatelessWidget {
  final BriefingEntry? briefingData;
  const GameBriefingScreen({Key? key, required this.briefingData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: briefingData == null
          ? const Center(
              child: Text('No mission data available yet.'),
            )
          : FractionallySizedBox(
              widthFactor: 0.85,
              child: briefingData!.profileEntries == null
                  ? const Center(
                      child: Text('No profiles available yet.'),
                    )
                  : Column(
                      children: [
                        const Center(
                          child: FittedBox(
                            child: Text(
                              'Profiles',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        SizedBox(
                          height: MediaQuery.of(context).size.width / 6,
                          child: Center(
                            child: ListView(
                              physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: List.generate(
                                briefingData!.profileEntries!.length,
                                (index) => ProfileButton(
                                    person:
                                        briefingData!.profileEntries![index]),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 50.0),
                        const Center(
                          child: FittedBox(
                            child: Text(
                              'Mission Briefing',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        briefingData!.briefing == null
                            ? const Text('No briefing available yet.')
                            : Text(
                                briefingData!.briefing!.replaceAll("\\n", "\n"),
                                textAlign: TextAlign.justify,
                              ),
                      ],
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
