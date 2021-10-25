import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/player.dart';
import 'package:strix/business_logic/classes/room.dart';
import 'package:strix/business_logic/logic/waiting_room_logic.dart';
import 'package:strix/services/service_locator.dart';
import 'package:strix/services/authorization/authorization_abstract.dart';
import 'package:strix/config/constants.dart';
import 'package:strix/ui/widgets/bordered_button.dart';
import 'package:strix/ui/widgets/top_icon.dart';

//import 'briefing_screen.dart';
import 'main_game_screen.dart';

class WaitingRoomScreen extends StatefulWidget {
  static const String routeId = 'waiting_room_screen';
  final String roomID;

  const WaitingRoomScreen({Key? key, required this.roomID}) : super(key: key);

  @override
  _WaitingRoomScreenState createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen>
    with SingleTickerProviderStateMixin {
  final Authorization _authorization = serviceLocator<Authorization>();
  late Animation _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Stream<Room?> roomStream =
        WaitingRoomLogic().roomDocStream(widget.roomID);
    int numberPlayers = 0;
    int minimumPlayers = 0;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                right: MediaQuery.of(context).size.width * 0.125,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: const Hero(
                    tag: 'strixIcon',
                    child: TopIcon(),
                  ),
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.16,
                  ),
                  Expanded(
                    flex: 20,
                    child: StreamBuilder(
                        // initialData: Room(
                        //   gameTitle: 'test',
                        //   roomID: '123456',
                        //   gameProgress: 'waiting',
                        //   players: [],
                        //   minimumPlayers: 1,
                        //   maximumPlayers: 10,
                        //   opened: DateTime.now(),
                        //   chat: Chat(messages: []),
                        // ),
                        stream: roomStream, // room snapshot or null on error
                        builder: (BuildContext context,
                            AsyncSnapshot<Room?> snapshot) {
                          Room? snapData = snapshot.data;
                          // check if stream is waiting for connection
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // TODO: IMPLEMENT LOADING SCREEN
                            return const Center(child: Text('LOADING!'));
                          }
                          // check if snapshot has room data
                          // todo: change after doc delete after left is implemented
                          else if (snapData == null) {
                            print('NO DATA COULD BE FETCHED!');
                            return Container(
                                //color: Colors.red,
                                );
                          }
                          // snapshot has room data
                          else {
                            // save for buttons important data in local variables
                            numberPlayers = snapData.players.length;
                            minimumPlayers = snapData.minimumPlayers;

                            // add callback to check for gamProgress change
                            // after every frame and move to game screen
                            WidgetsBinding.instance!.addPostFrameCallback(
                              (_) {
                                // check if game progress variable has changed from
                                // waiting status
                                if (snapData.gameProgress != kWaitingStatus) {
                                  // pop complete stack and move to the main game screen
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    MainGameScreen.routeId,
                                    (Route<dynamic> route) => false,
                                    arguments: widget.roomID,
                                  );
                                }
                              },
                            );

                            // initialize with dummy data
                            Player thisPlayer = noPlayer;
                            // find player in player list
                            try {
                              thisPlayer = snapData.players
                                  .where((Player player) =>
                                      player.uid ==
                                      _authorization.getCurrentUserID())
                                  .single;
                            } catch (e) {
                              print(
                                  'Error while fetching player data. Error: $e');
                              // todo : error handling when no player found?
                              // happens when player leaves and stream is still open
                            }
                            //print(thisPlayer);

                            return AnimatedBuilder(
                                animation: _animation,
                                builder: (context, child) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      //TopIcon(),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Transform(
                                            transform:
                                                Matrix4.translationValues(
                                                    _animation.value * 750,
                                                    0.0,
                                                    0.0),
                                            child: const FractionallySizedBox(
                                              widthFactor: 0.375,
                                              child: FittedBox(
                                                child: Text(
                                                  'mission',
                                                  style: TextStyle(
                                                    fontSize: 50.0,
                                                    fontFamily: 'Raleway',
                                                    fontWeight: FontWeight.w900,
                                                    fontStyle: FontStyle.italic,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Transform(
                                            transform:
                                                Matrix4.translationValues(
                                                    _animation.value * -800,
                                                    0.0,
                                                    0.0),
                                            child: FractionallySizedBox(
                                              widthFactor: 0.75,
                                              child: FittedBox(
                                                child: Text(
                                                  snapData.gameTitle
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 70.0,
                                                    fontFamily: 'Raleway',
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.greenAccent,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      Expanded(flex: 10, child: Container()),
                                      Column(
                                        children: [
                                          Transform(
                                            transform:
                                                Matrix4.translationValues(
                                                    _animation.value * -950,
                                                    0.0,
                                                    0.0),
                                            child: FractionallySizedBox(
                                              widthFactor: 0.75,
                                              child: FittedBox(
                                                child: Text(
                                                  snapData.roomID,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 70.0,
                                                    fontFamily: 'Raleway',
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 20.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Transform(
                                            transform:
                                                Matrix4.translationValues(
                                                    _animation.value * -1250,
                                                    0.0,
                                                    0.0),
                                            child: const FractionallySizedBox(
                                              widthFactor: 0.3,
                                              child: FittedBox(
                                                child: Text(
                                                  'session code',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 30.0,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Expanded(flex: 10, child: Container()),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          FractionallySizedBox(
                                            widthFactor: 0.75,
                                            child: Column(
                                              children: [
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Transform(
                                                    transform: Matrix4
                                                        .translationValues(
                                                            _animation.value *
                                                                -1200,
                                                            0.0,
                                                            0.0),
                                                    child: Text(
                                                      '${snapData.minimumPlayers} to ${snapData.maximumPlayers} agents needed',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontFamily: 'Raleway',
                                                        fontSize: 15.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 10.0),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 10.0,
                                                          ),
                                                          child: Transform(
                                                            transform: Matrix4
                                                                .translationValues(
                                                                    _animation
                                                                            .value *
                                                                        -2000,
                                                                    0.0,
                                                                    0.0),
                                                            child: FittedBox(
                                                              child: Icon(
                                                                snapData.players
                                                                            .length >
                                                                        0
                                                                    ? Icons
                                                                        .person
                                                                    : Icons
                                                                        .person_outline,
                                                                color: Colors
                                                                    .white,
                                                                size: 90.0,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10.0),
                                                          child: Transform(
                                                            transform: Matrix4
                                                                .translationValues(
                                                                    _animation
                                                                            .value *
                                                                        -1600,
                                                                    0.0,
                                                                    0.0),
                                                            child: FittedBox(
                                                              child: Container(
                                                                child: Icon(
                                                                  snapData.players
                                                                              .length >
                                                                          1
                                                                      ? Icons
                                                                          .person
                                                                      : Icons
                                                                          .person_outline,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 90.0,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10.0),
                                                          child: Transform(
                                                            transform: Matrix4
                                                                .translationValues(
                                                                    _animation
                                                                            .value *
                                                                        -1200,
                                                                    0.0,
                                                                    0.0),
                                                            child: FittedBox(
                                                              child: Container(
                                                                child: Icon(
                                                                  snapData.players
                                                                              .length >
                                                                          2
                                                                      ? Icons
                                                                          .person
                                                                      : Icons
                                                                          .person_outline,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 90.0,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10.0),
                                                          child: Transform(
                                                            transform: Matrix4
                                                                .translationValues(
                                                                    _animation
                                                                            .value *
                                                                        -800,
                                                                    0.0,
                                                                    0.0),
                                                            child: FittedBox(
                                                              child: Container(
                                                                child: Icon(
                                                                  snapData.players
                                                                              .length >
                                                                          3
                                                                      ? Icons
                                                                          .person
                                                                      : Icons
                                                                          .person_outline,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 90.0,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Transform(
                                                    transform: Matrix4
                                                        .translationValues(
                                                            _animation.value *
                                                                850,
                                                            0.0,
                                                            0.0),
                                                    child: Text(
                                                      snapData.players.length >
                                                              1
                                                          ? '${snapData.players.length} agents online'
                                                          : '${snapData.players.length} agent online',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontFamily: 'Raleway',
                                                        fontSize: 15.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                });
                          }
                        }),
                  ),
                  Expanded(flex: 2, child: Container()),
                  FractionallySizedBox(
                    widthFactor: 0.75,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            // leave the room
                            await WaitingRoomLogic().leaveRoom(
                              context: context,
                              animationController: _animationController,
                              roomID: widget.roomID,
                              numberPlayers: numberPlayers,
                            );
                          },
                          child: const Hero(
                            tag: 'button2',
                            child: Material(
                              color: Colors.transparent,
                              child: BorderedButton(
                                buttonText: 'back',
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            // try to start the game
                            await WaitingRoomLogic().startGame(
                              context: context,
                              numberPlayers: numberPlayers,
                              minimumPlayers: minimumPlayers,
                              roomID: widget.roomID,
                            );
                          },
                          child: const Hero(
                            tag: 'button1',
                            child: Material(
                              color: Colors.transparent,
                              child: BorderedButton(
                                buttonText: 'start',
                                fontSize: 18.0,
                                buttonColor: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(flex: 2, child: Container()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
