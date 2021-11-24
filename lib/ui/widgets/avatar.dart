import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/chat.dart';
import 'package:strix/ui/screens/profile_screen.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    Key? key,
    required this.fromTeam,
    required this.message,
  }) : super(key: key);

  final bool fromTeam;
  final Message message;

  final double radius = 10.0;
  final double imageSize = 0.11;
  final double coloredIconSize = 0.11;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: fromTeam ? const EdgeInsets.only(left: 10.0) : const EdgeInsets.only(right: 10.0),
      child: Container(
        height: fromTeam
            ? MediaQuery.of(context).size.width * coloredIconSize
            : MediaQuery.of(context).size.width * imageSize,
        width: fromTeam
            ? MediaQuery.of(context).size.width * coloredIconSize
            : MediaQuery.of(context).size.width * imageSize,
        decoration: message.author.profileImage == null
            ? BoxDecoration(
                shape: BoxShape.circle,
                color: message.author.color,
              )
            : BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: AssetImage('assets/profile_pictures/' + message.author.profileImage),
                    fit: BoxFit.cover),
              ),
        child: fromTeam
            ? Icon(
                Icons.person,
                color: Colors.white,
                size: MediaQuery.of(context).size.width * coloredIconSize * 0.7,
              )
            : RawMaterialButton(
                onPressed: () {
                  debugPrint(message.author);

                  Navigator.of(context).pushNamed(
                    ProfileScreen.routeId,
                    arguments: message.author,
                  );
                },
              ),
      ),
    );
  }
}
