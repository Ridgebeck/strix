import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:strix/business_logic/classes/marker.dart';
import 'package:strix/business_logic/classes/room.dart';
import 'package:strix/services/game_state/game_state_abstract.dart';
import 'package:strix/services/service_locator.dart';
import 'package:tuple/tuple.dart';

import 'next_milestone_logic.dart';

GameState _gameState = serviceLocator<GameState>();

// TODO: define as constants or get from settings
const double walkingSpeed = 70.0; // meters/sec
const double carSpeed = 60.0; // meters/sec
const int mapAnimTimeMs = 1500;

const markerSize = 45.0;
const personIndicatorSize = 28.0;
const double selectedMarkerFactor = 1.2;
const double inactiveMarkerFactor = 0.8;

class MapLogic {
  Tuple2<List<Marker>, List<Polyline>> createMarkersAndPolylines({
    required MapEntry mapData,
    required PageController pageController,
  }) {
    List<Marker> markers = [];
    List<Polyline> polylines = [];

    // sort markers by longitude (west to east)
    mapData.markerList.sort((a, b) => a.position.longitude.compareTo(b.position.longitude));

    // go through person marker list
    for (PersonMarkerData personMarkerData in mapData.personMarkerList) {
      // reset atLocation boolean to false
      personMarkerData.atLocation = false;

      // go through all markers
      for (MarkerData markerData in mapData.markerList) {
        // reset personHere list for specific marker
        markerData.personsHere = [];
        Distance distance = const Distance();

        // calculate distance between person and location
        final double distanceMeter = distance(
          personMarkerData.currentPosition,
          markerData.position,
        );
        // check if person is reasonably close to location
        if (distanceMeter < 50) {
          // check if path was followed to last waypoint
          if (personMarkerData.currentPosition == personMarkerData.positionPath.last) {
            // add them to list
            markerData.personsHere.add(personMarkerData.person);
            // flag them as being at a location
            personMarkerData.atLocation = true;
          }
        }

        // change markerSize if selected and/or active
        double adjustedMarkerSize = markerSize;
        double adjustedIndicatorSize = personIndicatorSize;
        if (markerData.selected) {
          if (markerData.active) {
            adjustedMarkerSize = markerSize * selectedMarkerFactor;
            adjustedIndicatorSize = personIndicatorSize * selectedMarkerFactor;
          }
        } else {
          if (markerData.active == false) {
            adjustedMarkerSize = markerSize * inactiveMarkerFactor;
            adjustedIndicatorSize = personIndicatorSize * inactiveMarkerFactor;
          }
        }
        markers.add(
          Marker(
            anchorPos: AnchorPos.align(AnchorAlign.top),
            width: adjustedMarkerSize + 200,
            height: adjustedMarkerSize + adjustedIndicatorSize / 2,
            point: markerData.position,
            builder: (context) => Stack(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(100, adjustedIndicatorSize / 2, 100, 0),
                  child: Container(
                    key: Key(markerData.name),
                    child: GestureDetector(
                      onTap: () {
                        // save new page number
                        _gameState.setMarkerTilePage(mapData.markerList.indexOf(markerData));

                        // move to correct page, this triggers also a map move
                        pageController.jumpToPage(
                          mapData.markerList.length * 100 + mapData.markerList.indexOf(markerData),
                        );
                      },
                      child: LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints constraints) {
                        double maxWidth = constraints.maxWidth;
                        double maxHeight = constraints.maxHeight;
                        return Stack(
                          children: [
                            // create glow if maker is selected
                            markerData.selected
                                ? Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: markerData.active
                                              ? markerData.type.color.withOpacity(0.5)
                                              : Colors.grey.withOpacity(0.5),
                                          blurRadius: 10.0,
                                        )
                                      ],
                                    ),
                                  )
                                // otherwise don't add glow
                                : Container(),

                            // solid colored background pin icon
                            Center(
                              child: FaIcon(
                                FontAwesomeIcons.mapMarker,
                                color: markerData.active ? markerData.type.color : Colors.grey,
                                size: maxHeight,
                              ),
                            ),

                            // add marker type icon
                            Positioned(
                              left: maxWidth / 2 - maxWidth / (2.2 * 2),
                              top: maxHeight / 2.2 - maxHeight / (2.2 * 2),
                              child: Icon(
                                markerData.type.icon,
                                color: Colors.white,
                                size: maxHeight / 2.2,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                Positioned(
                  top: 0.0,
                  left: 100.0 + adjustedMarkerSize * 1 / 2,
                  child: Row(
                    children: List.generate(
                      markerData.personsHere.length,
                      (index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Container(
                            width: adjustedIndicatorSize,
                            height: adjustedIndicatorSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage('assets/profile_pictures/' +
                                    markerData.personsHere[index].profileImage),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // go through person marker list
      for (PersonMarkerData personMarkerData in mapData.personMarkerList) {
        // add polylines to list
        if (personMarkerData.polyPositions != null) {
          if (personMarkerData.polyPositions!.length > 1) {
            polylines.add(Polyline(
              points: personMarkerData.polyPositions!,
              // make line invisible if person is at location
              strokeWidth: personMarkerData.atLocation ? 0.0 : 8.0,
              gradientColors: [
                Colors.green.withOpacity(0.9),
                Colors.greenAccent.withOpacity(0.5),
                Colors.greenAccent.withOpacity(0.6),
                Colors.lightBlueAccent.withOpacity(0.6),
              ],
              //color: Colors.green.withOpacity(0.7),
            ));
          }
        }

        markers.add(
          Marker(
            width: 35.0,
            height: 35.0,
            point: personMarkerData.currentPosition, // TODO: Adjust height for pin tip?
            builder: (context) => Opacity(
              opacity: personMarkerData.atLocation ? 0.0 : 1.0,
              child: Container(
                key: Key(personMarkerData.person.firstName + "location"),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/profile_pictures/' + personMarkerData.person.profileImage,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return Tuple2<List<Marker>, List<Polyline>>(markers, polylines);
  }
}

class MovingAnimation extends StatefulWidget {
  const MovingAnimation({Key? key}) : super(key: key);

  @override
  MovingAnimationState createState() => MovingAnimationState();
}

LatLng _correctedPosition({
  required double zoom,
  required LatLng position,
}) {
  // based on max zoom lvl 18
  double delta = 0.000625;
  double adjustment = delta;
  double base = 2;
  double adder;

  for (double x = 1; x < 18 - zoom; x++) {
    if (x < 18 - zoom - 1) {
      adder = pow(base, x) * delta;
    } else {
      adjustment = adjustment + delta;
      if (((18 - zoom) % 1) == 0) {
        adder = pow(base, x) * delta;
      } else {
        adder = ((18 - zoom) % 1) * pow(base, x) * delta;
      }
    }
    adjustment = adjustment + adder;
  }
  return LatLng(
    position.latitude - adjustment,
    position.longitude,
  );
}

class MovingAnimationState extends State<MovingAnimation> with TickerProviderStateMixin {
  @override
  void initState() {
    debugPrint("STATEFUL WIDGET INITIALIZED");
    super.initState();
  }

  @override
  void dispose() {
    debugPrint("STATEFUL WIDGET DISPOSED");
    super.dispose();
  }

  void animatedMapMove({
    required MapController mapController,
    required LatLng destLocation,
    double destZoom = 1,
    bool corrected = false,
  }) {
    // Create an animation controller that has a duration and a TickerProvider.
    AnimationController mapAnimController = AnimationController(
      duration: const Duration(milliseconds: mapAnimTimeMs),
      vsync: this,
    );

    // use current zoom if default was not changed
    if (destZoom == 1) {
      // use current zoom by default
      destZoom = mapController.zoom;
    }

    // correct position if required
    if (corrected) {
      destLocation = _correctedPosition(
        zoom: destZoom,
        position: destLocation,
      );
    }

    // calculate distance between current position and target
    LatLng startLocation = LatLng(mapController.center.latitude, mapController.center.longitude);
    Distance distance = const Distance();
    final double distanceMeter = distance(startLocation, destLocation);

    // only move if target is further than 50m away
    if (distanceMeter > 50) {
      // Create some tweens. These serve to split up the transition from one location to another.
      // In our case, we want to split the transition be<tween> our current map center and the destination.
      final _latTween =
          Tween<double>(begin: mapController.center.latitude, end: destLocation.latitude);
      final _lngTween =
          Tween<double>(begin: mapController.center.longitude, end: destLocation.longitude);
      final _zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

      // define animation
      Animation<double> animation = CurvedAnimation(
        parent: mapAnimController,
        curve: Curves.fastOutSlowIn,
      );

      // move to next milestone when animation is finished
      mapAnimController.addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          // save current center position
          _gameState.setCenterPosition(mapController.center);
          // save current current zoom level
          _gameState.setZoom(mapController.zoom);
          // dispose animation controller
          mapAnimController.dispose();
        }
        if (status == AnimationStatus.dismissed) {
          // dispose animation controller
          mapAnimController.dispose();
        }
      });

      // add listener to dynamically update values
      mapAnimController.addListener(() {
        // get state of map page
        State? mapPageState = _gameState.getMapState();
        // updating state of map screen

        if (mapPageState != null) {
          // check if page is mounted or was disposed
          if (mapPageState.mounted) {
            // send animated values to mapController
            mapController.move(
                LatLng(
                  _latTween.evaluate(animation),
                  _lngTween.evaluate(animation),
                ),
                _zoomTween.evaluate(animation));
            // update map screen
            mapPageState.setState(() {});
          }
        }
      });
      mapAnimController.forward();
    }
  }

  void startMovingAnimation({
    required String roomID,
    required PersonMarkerData personData,
  }) {
    List<LatLng> personPath = personData.positionPath;

    // calculate total distance
    Distance distance = const Distance();
    double totalPathDistance = 0;
    personPath.asMap().forEach((index, position) {
      if (index > 0) {
        totalPathDistance = totalPathDistance + distance(personPath[index - 1], personPath[index]);
      }
    });

    // initialize AnimationController with correct overall time
    AnimationController positionAnimController = AnimationController(
        duration: Duration(
            milliseconds:
                (totalPathDistance / (personData.onFoot ? walkingSpeed : carSpeed) * 1000).toInt()),
        vsync: this);

    // create lists for different latitude and longitude tween sequence items
    List<TweenSequenceItem<double>> _latTweenItems = [];
    List<TweenSequenceItem<double>> _longTweenItems = [];
    // create empty list for timing cues
    List<double> weightList = [0.0];

    // go through the path
    personPath.asMap().forEach((index, position) {
      if (index + 1 < personPath.length) {
        // save starting and end points
        LatLng startingPoint = personPath[index];
        LatLng endPoint = personPath[index + 1];
        // calculate waypoint distance
        final double waypointDistance = distance(startingPoint, endPoint);
        // calculate percentage of total distance (weight)
        final double waypointWeight = waypointDistance / totalPathDistance * 100;
        // add cumulative value (0.0 to 1.0) to weight list
        weightList.add(weightList.last + waypointWeight / 100);

        // create tween sequence items and add to list
        _latTweenItems.add(
          TweenSequenceItem<double>(
            tween: Tween<double>(
              begin: startingPoint.latitude,
              end: endPoint.latitude,
            ).chain(
              CurveTween(curve: Curves.linear),
            ),
            weight: waypointWeight,
          ),
        );
        _longTweenItems.add(
          TweenSequenceItem<double>(
            tween: Tween<double>(
              begin: startingPoint.longitude,
              end: endPoint.longitude,
            ).chain(
              CurveTween(curve: Curves.linear),
            ),
            weight: waypointWeight,
          ),
        );
      }
    });

    // create animations from tween sequence lists
    Animation<double> latAnimation =
        TweenSequence<double>(_latTweenItems).animate(positionAnimController);
    Animation<double> longAnimation =
        TweenSequence<double>(_longTweenItems).animate(positionAnimController);

    // make a copy of the path to modify positions
    // to create a dynamically changing polyline
    personData.polyPositions = (personPath).toList();

    // add current position as first entry to list
    personData.polyPositions = <LatLng>[personData.currentPosition] + personData.polyPositions!;

    // move to next milestone when animation is finished
    positionAnimController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await Future.delayed(const Duration(seconds: 3));
        await NextMilestoneLogic().moveToNextMilestone(roomID: roomID);
        positionAnimController.dispose();
      }
    });

    // add listener to dynamically update values
    positionAnimController.addListener(() {
      personData.currentPosition = LatLng(
        latAnimation.value,
        longAnimation.value,
      );

      // remove waypoints from polyline when animation passes
      if (positionAnimController.value >= weightList[0]) {
        weightList.removeAt(0);
        personData.polyPositions!.removeAt(1);
      }
      personData.polyPositions![0] = personData.currentPosition;

      // get state of map page
      State? mapPageState = _gameState.getMapState();

      // updating state of map screen
      try {
        if (mapPageState != null) {
          // check if page is mounted or was disposed
          if (mapPageState.mounted) {
            // update map screen
            mapPageState.setState(() {});
          }
        }
      } catch (error) {
        // TODO: error handling of callback function
        debugPrint("Error with callback: $error");
      }
    });

    // start animation
    try {
      positionAnimController.forward();
    } on TickerCanceled {
      debugPrint("Position AnimController Ticker got canceled");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
//
// void startMovingAnimation1(
//   String roomID,
//   //AnimationController positionAnimController,
//   TickerProviderStateMixin vsync,
//   List<LatLng> personPath,
//   //double totalPathDistance,
//   PersonMarkerData personData,
// ) {
//   // calculate total distance
//   Distance distance = const Distance();
//   double totalPathDistance = 0;
//   personPath.asMap().forEach((index, position) {
//     if (index > 0) {
//       totalPathDistance = totalPathDistance + distance(personPath[index - 1], personPath[index]);
//     }
//   });
//
//   AnimationController positionAnimController = AnimationController(
//       duration: Duration(
//           milliseconds:
//               (totalPathDistance / (personData.onFoot ? walkingSpeed : carSpeed) * 1000).toInt()),
//       vsync: vsync);
//
//   // create lists for different latitude and longitude tween sequence items
//   List<TweenSequenceItem<double>> _latTweenItems = [];
//   List<TweenSequenceItem<double>> _longTweenItems = [];
//   // create empty list for timing cues
//   List<double> weightList = [0.0];
//
//   // go through the path
//   personPath.asMap().forEach((index, position) {
//     if (index + 1 < personPath.length) {
//       // save starting and end points
//       LatLng startingPoint = personPath[index];
//       LatLng endPoint = personPath[index + 1];
//       // calculate waypoint distance
//       final double waypointDistance = distance(startingPoint, endPoint);
//       // calculate percentage of total distance (weight)
//       final double waypointWeight = waypointDistance / totalPathDistance * 100;
//       // add cumulative value (0.0 to 1.0) to weight list
//       weightList.add(weightList.last + waypointWeight / 100);
//
//       // create tween sequence items and add to list
//       _latTweenItems.add(
//         TweenSequenceItem<double>(
//           tween: Tween<double>(
//             begin: startingPoint.latitude,
//             end: endPoint.latitude,
//           ).chain(
//             CurveTween(curve: Curves.linear),
//           ),
//           weight: waypointWeight,
//         ),
//       );
//       _longTweenItems.add(
//         TweenSequenceItem<double>(
//           tween: Tween<double>(
//             begin: startingPoint.longitude,
//             end: endPoint.longitude,
//           ).chain(
//             CurveTween(curve: Curves.linear),
//           ),
//           weight: waypointWeight,
//         ),
//       );
//     }
//   });
//
//   // create animations from tween sequence lists
//   Animation<double> latAnimation =
//       TweenSequence<double>(_latTweenItems).animate(positionAnimController);
//   Animation<double> longAnimation =
//       TweenSequence<double>(_longTweenItems).animate(positionAnimController);
//
//   // make a copy of the path to modify positions
//   // to create a dynamically changing polyline
//   personData.polyPositions = (personPath).toList();
//   personData.polyPositions = [personData.currentPosition] + personData.polyPositions!;
//
//   // move to next milestone when animation is finished
//   positionAnimController.addStatusListener((status) async {
//     if (status == AnimationStatus.completed) {
//       await Future.delayed(const Duration(seconds: 3));
//       await NextMilestoneLogic().moveToNextMilestone(roomID: roomID);
//       positionAnimController.dispose();
//     }
//   });
//
//   // add listener to dynamically update values
//   positionAnimController.addListener(() {
//     personData.currentPosition = LatLng(
//       latAnimation.value,
//       longAnimation.value,
//     );
//
//     // remove waypoints from polyline when animation passes
//     if (positionAnimController.value >= weightList[0]) {
//       weightList.removeAt(0);
//       personData.polyPositions!.removeAt(1);
//     }
//     personData.polyPositions![0] = personData.currentPosition;
//     // change current position value of person marker
//     // TODO:STATE NEEDS TO BE UPDATED ON MAP PAGE!
//   });
//
//   // start animation
//   try {
//     positionAnimController.forward();
//   } on TickerCanceled {
//     print("Position AnimController Ticker got canceled");
//   }
// }
