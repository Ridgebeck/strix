//import 'dart:html';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/room.dart';
import 'package:expandable/expandable.dart';
import 'package:strix/config/constants.dart';

class GameMissionScreen extends StatefulWidget {
  final MissionEntry? missionData;
  const GameMissionScreen({Key? key, required this.missionData})
      : super(key: key);

  @override
  _GameMissionScreenState createState() => _GameMissionScreenState();
}

double _x = 0.0;
double _y = 0.0;

class _GameMissionScreenState extends State<GameMissionScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 60),
    vsync: this,
  )..repeat();
  final double widthFactor = 0.90;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // create empty list for whole screen stack
    List<Widget> missionScreenList = [];

    // create list for converted goal data
    List<Widget> goalList = [];

    // check if mission data is null
    if (widget.missionData == null) {
      // show placeholder if data is null
      return const Center(
        child: Text('No mission data available yet.'),
      );
    }
    // process mission data if available
    else {
      // check if goal list is not null
      if (widget.missionData!.goalList != null) {
        // go through goal in list and convert to MissionGoalWidget
        widget.missionData!.goalList!.forEach((element) {
          goalList.add(
            MissionGoalWidget(
              goal: element.goal,
              completed: element.completed,
              hints: element.hints ?? [],
            ),
          );
          goalList.add(
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          );
        });
      }

      // add objectives and map to list
      missionScreenList.add(
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FractionallySizedBox(
                  widthFactor: widthFactor,
                  child: Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                      const Center(
                        child: FittedBox(
                          child: Text(
                            'Mission Objective: Find Derek',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: goalList,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                SpinningMap(
                  controller: _controller,
                  mapPositionList:
                      widget.missionData!.mapPositions, //mapPositions,
                ),
              ],
            ),
          ),
        ),
      );

      // add moving indicators to list if any positions are present
      if (widget.missionData!.mapPositions != null) {
        widget.missionData!.mapPositions!.forEach((mapPosition) {
          if (mapPosition == widget.missionData!.mapPositions!.last) {}
          missionScreenList.add(
            MovingIndicator(
              controller: _controller,
              targetKey: mapPosition.markerKey,
              currentGoal: mapPosition.currentGoal,
              text: mapPosition.markerText,
            ),
          );
        });
      }

      // return Stack with list as children
      return Stack(children: missionScreenList);
    }
  }
}

class MissionGoalWidget extends StatelessWidget {
  final String goal;
  final bool completed;
  final List<String>? hints;

  const MissionGoalWidget({
    required this.goal,
    required this.completed,
    this.hints,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // create empty list for hint widgets
    List<Widget> hintEntryList = [];

    // check if hints are not null and not an empty list
    if (hints != null) {
      if (hints!.isNotEmpty) {
        // convert list of hint texts into formatted list
        hintEntryList.add(const SizedBox(height: 5.0));
        hints!.forEach((hintText) {
          hintEntryList.add(const SizedBox(height: 5.0));
          hintEntryList.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '\u2022 ',
                  style: TextStyle(color: kAccentColor),
                ),
                Expanded(
                  child: Text(
                    hintText,
                    style: const TextStyle(color: kAccentColor),
                  ),
                ),
              ],
            ),
          );
        });
      }
    }
    // return the fitting widget
    return completed == false
        ? hintEntryList.isEmpty
            ? Wrap(
                children: [
                  Text(
                    goal,
                    style: const TextStyle(
                      fontSize: 17.0,
                      color: kAccentColor,
                    ),
                  ),
                ],
              )
            : ExpandablePanel(
                header: Text(
                  goal,
                  style: const TextStyle(
                    fontSize: 17.0,
                    color: kAccentColor,
                  ),
                ),
                collapsed: Container(),
                expanded: Row(
                  children: [
                    const SizedBox(width: 25.0),
                    Expanded(
                      child: Column(children: hintEntryList),
                    ),
                  ],
                ),
                theme: const ExpandableThemeData(
                  iconColor: kAccentColor,
                  iconSize: 20.0,
                  iconPadding: EdgeInsets.all(0.0),
                ),
              )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal,
                  style: const TextStyle(
                    fontSize: 17.0,
                    decoration: TextDecoration.lineThrough,
                    //color: Colors.white,
                  ),
                ),
              ),
              const Icon(Icons.check),
            ],
          );
  }
}

class MovingIndicator extends AnimatedWidget {
  final GlobalKey targetKey;
  final bool currentGoal;
  final String text;
  const MovingIndicator({
    Key? key,
    required AnimationController controller,
    required this.targetKey,
    required this.currentGoal,
    required this.text,
  }) : super(key: key, listenable: controller);

  @override
  Widget build(BuildContext context) {
    try {
      if (targetKey.currentContext != null) {
        RenderBox box =
            targetKey.currentContext!.findRenderObject() as RenderBox;
        Offset position = box.localToGlobal(Offset.zero);
        _x = position.dx;
        _y = position.dy;
      }
    } catch (e) {
      print('Error while calculating position: $e');
    }

    double textWidth = 150.0;
    double textHeight = 17.0;
    double indicatorWidth = 2.0;
    double indicatorHeight = 50.0;
    double totalHeight = indicatorHeight + textHeight;

    return Positioned(
      left: _x - textWidth / 2,
      top: _y - totalHeight,
      child: Column(
        children: [
          SizedBox(
            width: textWidth,
            height: textHeight,
            child: FittedBox(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 50.0,
                  color: currentGoal ? kAccentColor : Colors.white,
                ),
              ),
            ),
          ),
          Container(
            color: currentGoal ? kAccentColor : Colors.white,
            width: indicatorWidth,
            height: indicatorHeight,
          ),
        ],
      ),
    );
  }
}

class SpinningMap extends AnimatedWidget {
  final List<MapPosition>? mapPositionList;
  const SpinningMap({
    Key? key,
    required AnimationController controller,
    this.mapPositionList,
  }) : super(key: key, listenable: controller);

  Animation<double> get _progress => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox(
        //color: Colors.blueGrey,
        height: MediaQuery.of(context).size.height * 0.5,
        width: double.infinity,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          double imageSize = constraints.maxWidth;
          double markerSize = 12.0;

          List<Widget> mapAndMarkers = [
            Container(
              height: imageSize,
              width: imageSize,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/pictures/map_square.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ];

          if (mapPositionList != null) {
            mapPositionList!.forEach((positionElement) {
              mapAndMarkers.add(
                MapMarker(
                  imageSize: imageSize,
                  markerSize: markerSize,
                  positionX: positionElement.positionX,
                  positionY: positionElement.positionY,
                  currentGoal: positionElement.currentGoal,
                  markerKey: positionElement.markerKey,
                ),
              );
            });
          }

          //Matrix4 transformMatrix = Matrix4.identity();
          Matrix4 transformMatrix = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(2 * math.pi * -62 / 360)
            ..rotateY(2 * math.pi * 0 / 360)
            ..rotateZ(_progress.value * 2.0 * math.pi)
            ..setTranslationRaw(
                0, MediaQuery.of(context).size.height * -0.06, 0)
            ..scale(1.2);

          return Center(
            child: Transform(
              alignment: Alignment.center,
              transform: transformMatrix,
              child: Stack(children: mapAndMarkers),
            ),
          );
        }),
      ),
    );
  }
}

class MapMarker extends StatelessWidget {
  const MapMarker({
    Key? key,
    required this.imageSize,
    required this.markerSize,
    required this.positionX,
    required this.positionY,
    required this.currentGoal,
    required this.markerKey,
  }) : super(key: key);

  final double imageSize;
  final double markerSize;
  final double positionX;
  final double positionY;
  final bool currentGoal;
  final GlobalKey markerKey;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: imageSize * positionX / 100 - markerSize / 2,
      top: imageSize * positionY / 100 - markerSize / 2,
      child: Container(
        height: markerSize,
        width: markerSize,
        decoration: BoxDecoration(
          color: currentGoal ? kAccentColor : Colors.white,
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: Center(
          child: SizedBox(
            key: markerKey,
            height: 1.0,
            width: 1.0,
          ),
        ),
      ),
    );
  }
}
