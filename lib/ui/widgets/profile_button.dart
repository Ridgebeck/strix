import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/person.dart';
import 'package:strix/config/constants.dart';
import 'package:strix/ui/screens/profile_screen.dart';

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
