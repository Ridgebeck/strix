import 'package:flutter/material.dart';
import 'package:strix/business_logic/logic/start_room_logic.dart';
import 'package:strix/ui/screens/join_room_screen.dart';
import 'package:strix/ui/screens/waiting_room_screen.dart';
import 'package:strix/ui/widgets/bordered_button.dart';
import 'package:strix/ui/widgets/top_icon.dart';

class StartJoinScreen extends StatefulWidget {
  static const String routeId = 'start_join_screen';

  const StartJoinScreen({Key? key}) : super(key: key);

  @override
  _StartJoinScreenState createState() => _StartJoinScreenState();
}

class _StartJoinScreenState extends State<StartJoinScreen> {
  bool tapped = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                const TopIcon(),
                Expanded(
                  flex: 3,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: Container()),
                      Expanded(
                        flex: 10,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              tapped = !tapped;
                            });
                          },
                          child: Stack(
                            children: [
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 3500),
                                curve: Curves.easeInOut,
                                top: 70.0,
                                left: tapped ? 70.0 : 100,
                                child: Text(
                                  'your mission',
                                  style: TextStyle(
                                    fontSize: 30.0,
                                    color: Colors.grey[900],
                                  ),
                                ),
                              ),
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 3500),
                                top: 25.0,
                                left: tapped ? 40.0 : 20,
                                child: const Text(
                                  'Welcome Agent',
                                  style: TextStyle(
                                    fontFamily: 'Raleway',
                                    fontSize: 35.0,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const AnimatedPositioned(
                                duration: Duration(milliseconds: 3500),
                                top: 110.0,
                                left: 60.0, //tapped ? 70.0 : 30,
                                child: Text(
                                  'GREEN LIGHT',
                                  style: TextStyle(
                                    fontFamily: 'Raleway',
                                    fontSize: 40.0,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Text(
                        //   '\n\n',
                        //   //'WELCOME TO\n MISSION GREEN LIGHT',
                        //   textAlign: TextAlign.center,
                        //   style: TextStyle(
                        //     color: Colors.lightGreenAccent,
                        //     fontSize: 30,
                        //   ),
                        // ),
                      ),
                      Expanded(child: Container()),
                    ],
                  ),
                ),
                Expanded(child: Container()),
                //Expanded(child: Container()),
                Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: const BorderedButton(
                        buttonText: 'How this works', fontSize: 20.0),
                  ),
                ),
                Expanded(child: Container()),
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      String? roomID = await StartRoomLogic().addRoom();
                      if (roomID == null) {
                        print('ERROR: could not add new game');
                        // TODO: show error pop up when game cannot be created
                      } else {
                        Navigator.of(context).pushReplacementNamed(
                          WaitingRoomScreen.routeId,
                          arguments: roomID,
                        );
                      }
                    },
                    child: const BorderedButton(
                        buttonText: 'Start a Mission', fontSize: 20.0),
                  ),
                ),
                Expanded(child: Container()),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pushReplacementNamed(JoinRoomScreen.routeId);
                    },
                    child: const BorderedButton(
                        buttonText: 'Join a Mission', fontSize: 20.0),
                  ),
                ),
                Expanded(flex: 2, child: Container()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
