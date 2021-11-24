import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/marker.dart';
import 'package:strix/business_logic/classes/room.dart';
import 'package:strix/business_logic/logic/map_logic.dart';
import 'package:strix/services/service_locator.dart';
import 'package:strix/services/authorization/authorization_abstract.dart';
import 'package:strix/ui/screens/icoming_call_screen.dart';
import 'package:strix/ui/widgets/bottom_tab_bar.dart';
import 'game_mission_screen.dart';
import 'game_map_screen.dart';
import 'data_screen.dart';
import 'chat_screen.dart';
import 'package:strix/business_logic/logic/waiting_room_logic.dart';

class MainGameScreen extends StatefulWidget {
  static const String routeId = 'main_game_screen';
  final String roomID;

  const MainGameScreen({Key? key, required this.roomID}) : super(key: key);

  @override
  _MainGameScreenState createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> with TickerProviderStateMixin {
  late Stream<Room?> roomStream;
  late TabController _tabController;
  final Authorization _authorization = serviceLocator<Authorization>();
  AvailableAssetEntry lastEntry = AvailableAssetEntry(entryName: "lastEntry");
  BuildContext? dialogContext;

  MissionEntry? currentMissionEntry;
  DataEntry? currentDataEntry;

  @override
  void initState() {
    //_gameState.setNavKey(navKey);
    super.initState();
    roomStream = WaitingRoomLogic().roomDocStream(widget.roomID);
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.index != 4) {
      FocusScope.of(context).unfocus();
    }
    if (_tabController.indexIsChanging == false) {
      if (_tabController.index == 0) {
        debugPrint('INDEX 0!');
        // reset briefing data indicator
        //newBriefingData = false;
      }
      if (_tabController.index == 1) {
        debugPrint('INDEX 1!');
        // reset mission data indicator
        //newMissionData = false;
      }
      if (_tabController.index == 2) {
        debugPrint('INDEX 2!');
      }
      if (_tabController.index == 3) {
        debugPrint('INDEX 3!');
        // reset chat data indicator
        //newChatMessage = false;
      }
    }

    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: roomStream,
      builder: (BuildContext context, AsyncSnapshot<Room?> snapshot) {
        Room? snapData = snapshot.data;
        if (snapData == null) {
          debugPrint('ERROR - data is null');
          // todo:error handling when data is null
          return Container();
        } else {
          // // check if new message was added
          // if (currentMessages != snapData.chat.messages.length) {
          //   currentMessages = snapData.chat.messages.length;
          //   newChatMessage = true;
          // } else {
          //   newChatMessage = false;
          // }

          // find current progress entry
          AvailableAssetEntry currentEntry = snapData.availableAssets
              .singleWhere((element) => element.entryName == snapData.gameProgress);

          // check if currentEntry is different from lastEntry
          // prevents opening calls multiple times
          if (currentEntry != lastEntry) {
            //set last entry to current one
            lastEntry = currentEntry;
            // check if current entry is a call
            if (currentEntry.call != null) {
              // add callback to check for gameProgress change
              // after every frame and move to call screen
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                debugPrint(currentEntry.call!.callFile);
                if (snapData.host == _authorization.getCurrentUserID()) {
                  Navigator.of(context).pushNamed(IncomingCallScreen.routeId, arguments: snapData);
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      dialogContext = context;
                      return const AlertDialog(
                        title: Text('Please Stand By'),
                        content: Text('Incoming call on other device.'),
                      );
                    },
                    barrierDismissible: false,
                  );
                }
              });
            }
            // when entry is not a call
            else {
              // close dialog box if context exists
              if (dialogContext != null) {
                Navigator.pop(dialogContext!);
                dialogContext = null;
              }

              // check if entry has map data
              if (currentEntry.map != null) {
                // check for all persons with a path longer than 1 point
                List<PersonMarkerData> personsMoving = currentEntry.map!.personMarkerList
                    .where((element) => element.positionPath.length > 1)
                    .toList();
                // TODO: currently only using one path (first found) --> allow multiple?
                if (personsMoving.isNotEmpty) {
                  PersonMarkerData personData = personsMoving[0];

                  debugPrint("${personData.person.firstName} is moving!");

                  // start calculating the move along path on map
                  const MovingAnimation().createState().startMovingAnimation(
                        roomID: widget.roomID,
                        personData: personData,
                      );
                }
              }

              // save current mission entry
              currentMissionEntry = currentEntry.mission;
              // save current data entry
              currentDataEntry = currentEntry.data;
            }
          }

          return WillPopScope(
            // don't allow moving back via system default
            onWillPop: () async => false,
            child: Scaffold(
              backgroundColor: Colors.grey[900],
              body: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  GameMissionScreen(
                    missionData: currentEntry.mission,
                  ),
                  GameMapScreen(
                    mapData: currentEntry.map,
                    roomID: widget.roomID,
                  ),
                  DataScreen(
                    assets: currentEntry,
                  ),
                  ChatScreen(
                    roomData: snapData,
                    //newMessage: newChatMessage,
                  ),
                ],
              ),
              bottomNavigationBar: BottomTabBar(
                tabController: _tabController,
                //newBriefingData: newBriefingData,
                //newMissionData: newMissionData,
                //newData: newData.anyNewData(),
                //newChatData: newChatMessage,
              ),
              extendBody: true,
            ),
          );
        }
      },
    );
  }
}
