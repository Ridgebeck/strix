import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:strix/config/constants.dart';
import 'package:strix/services/game_state/game_state.dart';
import 'package:strix/services/service_locator.dart';

import 'new_indicator_dot.dart';

class BottomTabBar extends StatelessWidget {
  final TabController tabController;
  final Radius bottomBarRadius;
  final GameState _gameState = serviceLocator<GameState>();

  BottomTabBar({
    Key? key,
    required this.tabController,
    required this.bottomBarRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        highlightColor: kAccentColor.withOpacity(0.2),
        splashColor: kAccentColor.withOpacity(0.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: bottomBarRadius,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: kGlassBlurriness,
            sigmaY: kGlassBlurriness,
          ),
          child: Material(
            color: Colors.transparent,
            elevation: kGlassElevation,
            child: Container(
              color: kGlassColor,
              child: TabBar(
                indicatorColor: kAccentColor,
                labelColor: kSelectedTabColor,
                unselectedLabelColor: kUnselectedTabColor,
                controller: tabController,
                tabs: [
                  SelectableTab(
                    tabController: tabController,
                    iconData: Icons.folder_open,
                    text: 'Mission',
                    newData: _gameState.newData.newMissionData,
                    index: kMissionTabIndex,
                  ),
                  SelectableTab(
                    tabController: tabController,
                    iconData: Icons.map,
                    text: 'Map',
                    newData: _gameState.newData.newMapData,
                    index: kMapTabIndex,
                  ),
                  SelectableTab(
                    tabController: tabController,
                    iconData: Icons.cloud_outlined,
                    text: 'Data',
                    newData: _gameState.newData.newMediaData.isThereNewData(),
                    index: kDataTabIndex,
                  ),
                  SelectableTab(
                    tabController: tabController,
                    iconData: Icons.chat_bubble_outline,
                    text: 'Chat',
                    newData: _gameState.newData.newChatData,
                    index: kChatTabIndex,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
          NewIndicatorDot(newData: newData),
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
