import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:strix/config/constants.dart';

Color kSelectedTabColor = Colors.white;
Color kUnselectedTabColor = Colors.blueGrey;

class BottomTabBar extends StatelessWidget {
  final TabController tabController;
  final bool newBriefingData;
  final bool newMissionData;
  final bool newData;
  final bool newChatData;

  const BottomTabBar({
    Key? key,
    required this.tabController,
    required this.newBriefingData,
    required this.newMissionData,
    required this.newData,
    required this.newChatData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      indicatorColor: kAccentColor,
      labelColor: kSelectedTabColor,
      unselectedLabelColor: kUnselectedTabColor,
      controller: tabController,
      tabs: [
        SelectableTab(
          tabController: tabController,
          iconData: Icons.folder_open,
          text: 'Briefing',
          newData: newBriefingData,
          index: 0,
        ),
        SelectableTab(
          tabController: tabController,
          iconData: Icons.list,
          text: 'Mission',
          newData: newMissionData,
          index: 1,
        ),
        SelectableTab(
          tabController: tabController,
          iconData: Icons.cloud_outlined,
          text: 'Data',
          newData: newData,
          index: 2,
        ),
        SelectableTab(
          tabController: tabController,
          iconData: Icons.chat_bubble_outline,
          text: 'Chat',
          newData: newChatData,
          index: 3,
        ),
      ],
    );
  }
}

class SelectableTab extends StatelessWidget {
  const SelectableTab({
    Key? key,
    required this.tabController,
    required this.iconData,
    required this.text,
    required this.newData,
    required this.index,
  }) : super(key: key);

  final TabController tabController;
  final bool newData;
  final String text;
  final int index;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return Tab(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            iconData,
            color: tabController.index == index
                ? kSelectedTabColor
                : newData
                    ? kAccentColor
                    : kUnselectedTabColor,
          ),
          Positioned(
            right: -10.0,
            top: -10.0,
            child: Visibility(
              visible: tabController.index == index
                  ? false
                  : newData
                      ? true
                      : false,
              child: Container(
                width: 10.0,
                height: 10.0,
                decoration: BoxDecoration(
                  color: kAccentColor,
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: tabController.index == index
              ? kSelectedTabColor
              : newData
                  ? kAccentColor
                  : kUnselectedTabColor,
        ),
      ),
    );
  }
}