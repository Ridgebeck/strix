import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/dynamic_data.dart';
import 'package:strix/business_logic/classes/goals.dart';
import 'package:strix/business_logic/classes/marker.dart';
import 'package:strix/business_logic/classes/static_data.dart';
import 'package:strix/business_logic/logic/map_logic.dart';
import 'package:strix/business_logic/logic/waiting_room_logic.dart';
import 'package:strix/config/constants.dart';
import 'package:strix/services/game_state/game_state.dart';
import 'package:strix/services/service_locator.dart';
import 'package:strix/services/authorization/authorization_abstract.dart';
import 'package:strix/ui/screens/icoming_call_screen.dart';
import 'package:strix/ui/widgets/bottom_tab_bar.dart';
import 'game_mission_screen.dart';
import 'game_map_screen.dart';
import 'data_screen.dart';
import 'chat_screen.dart';

class MainGameScreen extends StatefulWidget {
  static const String routeId = 'main_game_screen';
  final String roomID;

  const MainGameScreen({Key? key, required this.roomID}) : super(key: key);

  @override
  _MainGameScreenState createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> with TickerProviderStateMixin {
  late Stream<DynamicData?> dataStream;
  late StaticData? staticData;
  late TabController _tabController;
  final Authorization _authorization = serviceLocator<Authorization>();
  final GameState _gameState = serviceLocator<GameState>();
  BuildContext? dialogContext;

  // helper variables to check for changes
  AvailableAssetEntry lastEntry = AvailableAssetEntry(entryName: "lastEntry");
  List<GoalAndHints> lastGoalsAndHints = [GoalAndHints(goal: "no goal yet")];

  late Radius bottomBarRadius;

  @override
  void initState() {
    bottomBarRadius = kBottomBarRadius;
    super.initState();
    // get static data
    staticData = _gameState.staticData;
    // create data stream for dynamic data
    dataStream = WaitingRoomLogic().dynamicDataStream(roomID: widget.roomID);
    // create tab controller and add listener
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    // close keyboard if not on chat screen
    if (_tabController.index != 3) {
      FocusScope.of(context).unfocus();
    }
    if (_tabController.indexIsChanging == false) {
      if (_tabController.index == kMissionTabIndex) {
        //debugPrint('INDEX $kMissionTabIndex - MISSION!');
        bottomBarRadius = kBottomBarRadius;
        _gameState.newData.newMissionData = false;
      }
      if (_tabController.index == kMapTabIndex) {
        //debugPrint('INDEX $kMapTabIndex - MAP!');
        bottomBarRadius = kBottomBarRadius;
        _gameState.newData.newMapData = false;
      }
      if (_tabController.index == kDataTabIndex) {
        //debugPrint('INDEX $kDataTabIndex - DATA!');
        bottomBarRadius = kBottomBarRadius;
        // reset all media booleans to false
        _gameState.newData.newMediaData.reset();
      }
      if (_tabController.index == kChatTabIndex) {
        //debugPrint('INDEX $kChatTabIndex - CHAT!');
        // change tab bar radius
        bottomBarRadius = const Radius.circular(0.0);
        _gameState.newData.newChatData = false;
      }
    }

    // update screen with new radius of bottom bar
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("NEW GAME SCREEN BUILD");

    return StreamBuilder(
      stream: dataStream,
      builder: (BuildContext context, AsyncSnapshot<DynamicData?> snapshot) {
        DynamicData? dynamicData = snapshot.data;
        if (dynamicData == null) {
          debugPrint('ERROR - dynamic data is null');
          // todo:error handling when dynamic data is null
          return Container();
        }
        if (staticData == null) {
          debugPrint('ERROR - static data is null');
          // todo:error handling when static data is null
          return Container();
        }

        // TODO: SAVE PLAYER DATA + UID LOCALLY ONLY ONCE WHEN GAME STARTS
        // save user specific player object
        _gameState.userPlayerData = dynamicData.players
            .singleWhere((player) => player.uid == _authorization.getCurrentUserID());

        // find current entry of assets (progress in story)
        AvailableAssetEntry currentEntry = staticData!.availableAssets[dynamicData.gameProgressID];

        // check if goals have changed
        if (lastGoalsAndHints != dynamicData.currentGoals) {
          if (_tabController.index != kMissionTabIndex) {
            // set new mission data to true
            _gameState.newData.newMissionData = true;
          }
          // save current goals
          lastGoalsAndHints = dynamicData.currentGoals;
        }

        // check if asset entry has changed (game has progressed)
        if (currentEntry != lastEntry) {
          print("NEW ASSET ENTRY FOUND!");

          // check if map data has changed
          if (currentEntry.map != lastEntry.map && _tabController.index != kMapTabIndex) {
            // set new map data to true
            _gameState.newData.newMapData = true;
          }

          // check if mission data has changed (profiles + briefing only!)
          if (currentEntry.mission != lastEntry.mission &&
              _tabController.index != kMissionTabIndex) {
            // set new mission data to true
            _gameState.newData.newMissionData = true;
          }

          // check if media data has changed
          if (currentEntry.data != lastEntry.data && _tabController.index != kDataTabIndex) {
            if (currentEntry.data != null && lastEntry.data != null) {
              for (DataType type in DataType.values) {
                if (!listEquals(
                    currentEntry.data!.getData(type: type), lastEntry.data!.getData(type: type))) {
                  _gameState.newData.newMediaData.setNewData(type: type);
                }
              }
            }
          }

          // save new entry as last entry to track future changes
          lastEntry = currentEntry;

          // check if current entry has a call object
          if (currentEntry.call != null) {
            // add callback to check for gameProgress change
            // after every frame and move to call screen
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              // only show call on host screen
              if (dynamicData.host == _authorization.getCurrentUserID()) {
                Navigator.of(context)
                    .pushNamed(IncomingCallScreen.routeId, arguments: currentEntry.call);
              }
              // otherwise show standby message
              else {
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
                      personData: personData,
                    );
              }
            }
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
                  dynamicData: dynamicData,
                ),
                GameMapScreen(
                  mapData: currentEntry.map,
                ),
                DataScreen(
                  data: currentEntry.data,
                  hasInsta: dynamicData.hasInsta,
                ),
                const ChatScreen(),
              ],
            ),
            bottomNavigationBar: BottomTabBar(
              tabController: _tabController,
              bottomBarRadius: bottomBarRadius,
            ),
            extendBody: true,
          ),
        );
      },
    );
  }
}
