import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/person.dart';
import 'package:strix/config/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  static const String routeId = 'profile_screen';
  final Person person;

  const ProfileScreen({
    Key? key,
    required this.person,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      //backgroundColor: Colors.black,
      body: Stack(children: [
        Column(
          children: [
            ClipPath(
              clipper: MyDiagonalClipper(),
              child: Container(
                height: screenHeight / 2,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/profile_pictures/' + person.profileImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(),
            ),
            Expanded(
              flex: 95,
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.title,
                      style: TextStyle(
                        color: Colors.blueGrey[100],
                        fontSize: 15.0,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      '${person.firstName} ${person.lastName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30.0,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      children: [
                        Expanded(child: Container()),
                        Expanded(
                          flex: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\u2022 profession: ${person.profession}',
                                style: TextStyle(
                                  color: Colors.blueGrey[100],
                                  fontSize: 16.0,
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              Text(
                                '\u2022 age: ${person.age}',
                                style: TextStyle(
                                  color: Colors.blueGrey[100],
                                  fontSize: 16.0,
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              // person.hobbies == null
                              //     ? Container()
                              Column(
                                children: [
                                  Text(
                                    '\u2022 hobbies: ${person.hobbies}',
                                    style: TextStyle(
                                      color: Colors.blueGrey[100],
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                ],
                              ),
                              person.instagram == null
                                  ? Container()
                                  : Row(
                                      children: [
                                        Text(
                                          '\u2022 Instagram: ',
                                          style: TextStyle(
                                            color: Colors.blueGrey[100],
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.all(0),
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            minimumSize: const Size(0, 0),
                                          ),
                                          onPressed: () {
                                            debugPrint('launch?');
                                            launch(
                                                'https://www.instagram.com/' + person.instagram!);
                                          },
                                          child: Text(
                                            '@' + person.instagram!,
                                            style: TextStyle(
                                              color: Colors.blueGrey[100],
                                              fontSize: 16.0,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10.0,
          left: MediaQuery.of(context).padding.left + 10.0,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: kAccentColor,
            splashColor: kBackgroundColorLight,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.navigate_before_sharp,
              color: Colors.black,
            ),
          ),
        ),
      ]),
    );
  }
}

class MyDiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0.0);
    path.lineTo(size.width, size.height * 0.75);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return false;
  }
}
