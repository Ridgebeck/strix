import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/dynamic_data.dart';
import 'package:strix/business_logic/logic/chat_room_logic.dart';
import 'package:strix/business_logic/logic/main_game_screen_logic.dart';
import 'package:strix/config/constants.dart';
import 'package:strix/ui/screens/chat_screen.dart';
import 'package:strix/ui/screens/incoming_call_screen.dart';
import 'package:strix/ui/widgets/bottom_tab_bar.dart';
import 'game_mission_screen.dart';
import 'game_map_screen.dart';
import 'data_screen.dart';

class MainGameScreen extends StatefulWidget {
  static const String routeId = 'main_game_screen';
  final String roomID;

  const MainGameScreen({Key? key, required this.roomID}) : super(key: key);

  @override
  _MainGameScreenState createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> with TickerProviderStateMixin {
  late Stream<DynamicData?> dynamicDataStream;
  late TabController _tabController;
  BuildContext? dialogContext;
  late Radius bottomBarRadius;
  final MainGameScreenLogic mainLogic = MainGameScreenLogic();

  @override
  void initState() {
    bottomBarRadius = kBottomBarRadius;
    super.initState();
    // create data stream for dynamic data
    dynamicDataStream = mainLogic.getDynamicDataStream(roomID: widget.roomID);
    // create tab controller and add listener
    _tabController = TabController(length: kTabLength, vsync: this);
    _tabController.addListener(_handleTabSelection);

    // listen to chat stream to check if there are new messages
    ChatRoomLogic().getChatStream(roomID: widget.roomID).listen((data) {
      mainLogic.checkForNewMessages(data: data, tabIndex: _tabController.index);
    });
  }

  void _handleTabSelection() {
    // close keyboard if not on chat screen
    if (_tabController.index != kChatTabIndex) {
      FocusScope.of(context).unfocus();
    }
    if (!_tabController.indexIsChanging) {
      // reset new goal or hint indicator when on mission screen
      if (_tabController.index == kMissionTabIndex) {
        mainLogic.resetGoalNotifier();
      }
      // reset new chat indicator when on chat screen
      if (_tabController.index == kChatTabIndex) {
        mainLogic.resetChatNotifier();
      }
    }

    // TODO: good practice or unnecessary work?
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
      stream: dynamicDataStream,
      builder: (BuildContext context, AsyncSnapshot<DynamicData?> snapshot) {
        DynamicData? dynamicData = snapshot.data;
        if (dynamicData == null) {
          debugPrint('ERROR - dynamic data is null');
          // todo:error handling when dynamic data is null
          return Container();
        }

        // TODO: SAVE PLAYER DATA + UID LOCALLY ONLY ONCE WHEN GAME STARTS?
        mainLogic.savePlayerData(dynamicData: dynamicData);

        // checking for new data entries
        mainLogic.checkForNewData(dynamicData: dynamicData, tabIndex: _tabController.index);

        // check for calls
        if (mainLogic.hasNewCall(dynamicData: dynamicData)) {
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            // only show call on host screen
            if (mainLogic.userIsHost(dynamicData: dynamicData)) {
              Navigator.of(context).pushNamed(IncomingCallScreen.routeId,
                  arguments: mainLogic.getCurrentEntry(dynamicData: dynamicData).call);
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
        } else {
          // close dialog box if context exists
          if (dialogContext != null) {
            Navigator.pop(dialogContext!);
            dialogContext = null;
          }

          // move person markers on map if entry has a path
          mainLogic.movePersonsOnMap(dynamicData: dynamicData);
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
                  mapData: mainLogic.getCurrentEntry(dynamicData: dynamicData).map,
                ),
                DataScreen(
                  data: mainLogic.getCurrentEntry(dynamicData: dynamicData).data,
                  hasInsta: dynamicData.hasInsta,
                ),
                ChatScreen(roomID: mainLogic.getRoomID(dynamicData: dynamicData)),
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
