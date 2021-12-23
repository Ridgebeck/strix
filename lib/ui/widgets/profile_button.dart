import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/person.dart';
import 'package:strix/config/constants.dart';
import 'package:strix/ui/screens/profile_screen.dart';
import 'package:strix/ui/widgets/new_indicator_dot.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({
    Key? key,
    required this.person,
  }) : super(key: key);

  final Person person;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: MediaQuery.of(context).size.width / 4 - 20.0,
            width: MediaQuery.of(context).size.width / 4 - 20.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              image: DecorationImage(
                image: AssetImage(
                  'assets/profile_pictures/' + person.profileImage,
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50.0),
              child: RawMaterialButton(
                splashColor: kSplashColor,
                onPressed: () {
                  person.isNew = false;
                  // check if there are no new profiles left
                  //_gameState.newData.newMapDataNotifier.value = mapData.hasNewMarkers();

                  Navigator.of(context).pushNamed(
                    ProfileScreen.routeId,
                    arguments: person,
                  );
                },
              ),
            ),
          ),
        ),
        NewIndicatorDot(
          newData: person.isNew,
          isInside: true,
        ),
      ],
    );
  }
}
