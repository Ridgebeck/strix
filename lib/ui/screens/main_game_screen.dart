import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/new_data.dart';
import 'package:strix/business_logic/classes/room.dart';
import 'package:strix/config/constants.dart';
import 'package:strix/services/service_locator.dart';
import 'package:strix/services/authorization/authorization_abstract.dart';
import 'package:strix/ui/screens/icoming_call_screen.dart';
import 'package:strix/ui/widgets/bottom_tab_bar.dart';
import 'game_briefing_screen.dart';
import 'game_mission_screen.dart';
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

class _MainGameScreenState extends State<MainGameScreen>
    with SingleTickerProviderStateMixin {
  late Stream<Room?> roomStream;
  late TabController _tabController;
  final Authorization _authorization = serviceLocator<Authorization>();
  AvailableAssetEntry lastEntry = AvailableAssetEntry(entryName: "lastEntry");
  BuildContext? dialogContext;

  bool newBriefingData = false;
  bool newMissionData = false;

  NewData newData = NewData();

  int currentMessages = 0;
  bool newChatMessage = false;

  BriefingEntry? currentBriefingEntry;
  MissionEntry? currentMissionEntry;
  DataEntry? currentDataEntry;

  @override
  void initState() {
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
        print('INDEX 0!');
        // reset briefing data indicator
        newBriefingData = false;
      }
      if (_tabController.index == 1) {
        print('INDEX 1!');
        // reset mission data indicator
        newMissionData = false;
      }
      if (_tabController.index == 2) {
        print('INDEX 2!');
      }
      if (_tabController.index == 3) {
        print('INDEX 3!');
        // reset chat data indicator
        newChatMessage = false;
      }
    }

    setState(() {});
  }

  void resetNewData(String category) {
    print('reset function invoked!');
    print(category);
    switch (category) {
      case DataSelection.images:
        {
          newData.newImages = false;
        }
        break;
      case DataSelection.messages:
        {
          newData.newMessages = false;
        }
        break;
      case DataSelection.social:
        {
          newData.newSocial = false;
        }
        break;
      // TODO: default category error handling
      default:
        {
          print('reset category not found!');
        }
        break;
    }
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
          print('ERROR - data is null');
          // todo:error handling when data is null
          return Container();
        } else {
          // check if new message was added
          if (currentMessages != snapData.chat.messages.length) {
            currentMessages = snapData.chat.messages.length;
            newChatMessage = true;
          } else {
            newChatMessage = false;
          }

          // find current progress entry
          AvailableAssetEntry currentEntry = snapData.availableAssets
              .singleWhere(
                  (element) => element.entryName == snapData.gameProgress);

          print("--------- LAST ENTRY: ${lastEntry.entryName}");
          print("--------- CURRENT ENTRY: ${currentEntry.entryName}");
          // check if currentEntry is different from lastEntry
          // prevents opening calls multiple times
          if (currentEntry != lastEntry) {
            print("--------- CURRENT ENTRY HAS CHANGED!!!");
            //set last entry to current one
            lastEntry = currentEntry;
            // check if current entry is a call
            if (currentEntry.call != null) {
              // add callback to check for gameProgress change
              // after every frame and move to call screen
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                print(currentEntry.call!.callFile);
                if (snapData.host == _authorization.getCurrentUserID()) {
                  Navigator.of(context).pushNamed(IncomingCallScreen.routeId,
                      arguments: snapData);
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

              // check if briefing data was not null
              if (currentBriefingEntry != null) {
                print('checking profile entries');
                print(currentBriefingEntry!.profileEntries!.length);
                print(currentEntry.briefing!.profileEntries!.length);
                // check if new profiles are present
                if (currentEntry.briefing!.profileEntries!.length >
                    currentBriefingEntry!.profileEntries!.length) {
                  newBriefingData = true;
                } else {
                  newBriefingData = false;
                }
              }

              // check if mission data was not null
              if (currentMissionEntry != null) {
                // check if number of goals or number of hints for current goal has changed
                if (currentMissionEntry!.goalList!.length ==
                        currentEntry.mission!.goalList!.length &&
                    currentMissionEntry!.goalList!.first.hints!.length ==
                        currentEntry.mission!.goalList!.first.hints!.length) {
                  newMissionData = false;
                } else {
                  newMissionData = true;
                }
              }

              // check if data was not null
              if (currentDataEntry != null) {
                // do not highlight when data is null
                if (currentEntry.data == null) {
                  // reset everything to false
                  newData = NewData();
                } else {
                  // TODO: use loop to go through all properties (mirror?)
                  // check if images are not null
                  if (currentEntry.data!.images != null) {
                    // if there were no entries before always highlight as new
                    if (currentDataEntry!.images == null) {
                      newData.newImages = true;
                      print('new images!');
                    }
                    // otherwise only highlight if there are more entries then before
                    else if (currentEntry.data!.images!.length >
                        currentDataEntry!.images!.length) {
                      print('more images!');
                      newData.newImages = true;
                    }
                  }

                  // check if messages are not null
                  if (currentEntry.data!.messages != null) {
                    // if there were no entries before always highlight as new
                    if (currentDataEntry!.messages == null) {
                      newData.newMessages = true;
                      print('new messages!');
                    }
                    // otherwise only highlight if there are more entries then before
                    else if (currentEntry.data!.messages!.length >
                        currentDataEntry!.messages!.length) {
                      print('more messages!');
                      newData.newMessages = true;
                    }
                  }

                  // check if social is not null
                  if (currentEntry.data!.social != null) {
                    // if there were no entries before always highlight as new
                    if (currentDataEntry!.social == null) {
                      newData.newSocial = true;
                      print('new social data!');
                    }
                    // otherwise only highlight if there are more entries then before
                    else if (currentEntry.data!.social!.length >
                        currentDataEntry!.social!.length) {
                      print('more social data!');
                      newData.newSocial = true;
                    }
                  }
                }
              }
              // save current briefing entry
              currentBriefingEntry = currentEntry.briefing;
              // save current mission entry
              currentMissionEntry = currentEntry.mission;
              // save current data entry
              currentDataEntry = currentEntry.data;
            }
          }

          return WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              body: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  GameBriefingScreen(briefingData: currentEntry.briefing),
                  GameMissionScreen(missionData: currentEntry.mission),
                  DataScreen(
                    assets: currentEntry,
                    newData: newData,
                    resetFunction: resetNewData,
                  ),
                  //ToolsScreen(),
                  ChatScreen(roomData: snapData, newMessage: newChatMessage),
                ],
              ),
              bottomNavigationBar: BottomTabBar(
                tabController: _tabController,
                newBriefingData: newBriefingData,
                newMissionData: newMissionData,
                newData: newData.anyNewData(),
                newChatData: newChatMessage,
              ),
              //backgroundColor: kBackgroundColorLight,
            ),
          );
        }
      },
    );
  }
}
