import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:strix/business_logic/classes/marker.dart';
import 'package:strix/business_logic/classes/person.dart';
import 'package:strix/business_logic/classes/room.dart';
import 'package:latlong2/latlong.dart';
import 'package:strix/business_logic/logic/map_logic.dart';
import 'package:strix/config/constants.dart';

// TODO: make constants or add to theme (see also bottom tab bar)
Color glassColor = Colors.black.withOpacity(0.25);
const double kGlassBlurriness = 15.0;
const double glassElevation = 2.0;

// TODO: import starting position or calculate from map
LatLng startingPoint = LatLng(37.7691, -122.4393);
// define standard boundaries for initial zoom lvl 12
LatLng nePanBoundary = LatLng(37.7845, -122.4250);
LatLng swPanBoundary = LatLng(37.7720, -122.4590);

// TODO: get values from map settings
const double initialZoom = 12.5;
const double minimalZoom = 12.0;
const double maxZoom = 16.0;
const markerSize = 40.0;
const double selectedMarkerFactor = 1.2;
const double inactiveMarkerFactor = 0.8;
const mapBackgroundColor = Color(0xFF212121);

// TODO: LOAD MARKER DATA FROM AVAILABLE ASSETS
var markerDataList = <MarkerData>[
  MarkerData(
    name: "Derek's Apartment",
    position: LatLng(37.77155, -122.44866),
    type: MarkerType.residential,
    infoText:
        "This is Derek's apartment. super long description: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas maximus ligula a purus tristique, nec faucibus magna gravida. Quisque non auctor sapien. Fusce dictum est sed nunc dignissim, eget consequat ante lobortis. Maecenas lobortis pretium tempus. Donec quis nunc interdum, suscipit mi sit amet, posuere purus. Interdum et malesuada fames ac ante ipsum primis in faucibus. Nullam ut orci diam. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Suspendisse quis commodo nunc. Mauris non interdum risus, in vestibulum justo. Ut vel nulla ut lectus ultrices porta.Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas maximus ligula a purus tristique, nec faucibus magna gravida. Quisque non auctor sapien. Fusce dictum est sed nunc dignissim, eget consequat ante lobortis. Maecenas lobortis pretium tempus. Donec quis nunc interdum, suscipit mi sit amet, posuere purus. Interdum et malesuada fames ac ante ipsum primis in faucibus. Nullam ut orci diam. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Suspendisse quis commodo nunc. Mauris non interdum risus, in vestibulum justo. Ut vel nulla ut lectus ultrices porta.",
  ),
  MarkerData(
    name: 'Agent Location',
    position: LatLng(37.77767, -122.44866),
    type: MarkerType.agent,
    infoText: "Agent is here",
    person: Person(
      firstName: "John",
      lastName: "Mason",
      profileImage: "russ.jpeg",
      title: "Field Agent",
    ),
    // atLocation: 'Books and Beyond',
  ),
  MarkerData(
    name: 'The Great Escape',
    position: LatLng(37.77267, -122.43753),
    type: MarkerType.store,
    infoText: "The best board game store in town.",
  ),
  MarkerData(
    name: 'The Grocery Store',
    position: LatLng(37.77767, -122.43817),
    type: MarkerType.store,
  ),
  MarkerData(
    name: 'Books and Beyond',
    position: LatLng(37.78307, -122.46471),
    type: MarkerType.store,
  ),
  MarkerData(
    name: 'Burgers & More',
    position: LatLng(37.76969, -122.44842),
    type: MarkerType.restaurant,
  ),
  MarkerData(
    name: 'Cafe Ole',
    position: LatLng(37.80471, -122.41199),
    type: MarkerType.restaurant,
  ),
  MarkerData(
    name: 'Bar Mitzvah',
    position: LatLng(37.76943, -122.45262),
    type: MarkerType.restaurant,
  ),
];

class GameMapScreen extends StatefulWidget {
  // TODO: Change to map data
  final MissionEntry? missionData;
  const GameMapScreen({
    Key? key,
    required this.missionData,
  }) : super(key: key);

  @override
  _GameMapScreenState createState() => _GameMapScreenState();
}

class _GameMapScreenState extends State<GameMapScreen> with TickerProviderStateMixin {
  // late init controllers and stream subscription
  late final MapController mapController;
  late final PageController pageController;
  late final StreamSubscription<MapEvent> mapEventSubscription;

  // variables to show / expand marker menu
  bool showMarkerDetails = false;
  bool fullyExpanded = false;

  @override
  void initState() {
    super.initState();
    // initialize controllers
    mapController = MapController();
    pageController = PageController(viewportFraction: 0.90, initialPage: 999);

    // when controller is ready
    mapController.onReady.then((_) {
      // start stream subscription to catch controller events
      mapEventSubscription = mapController.mapEventStream.listen((event) {
        if (event is MapEventMoveEnd) {
          // define boundaries based on zoom level
          // TODO: load boundaries from settings?
          if (mapController.zoom <= 12) {
            nePanBoundary = LatLng(37.7845, -122.4250);
            swPanBoundary = LatLng(37.7720, -122.4590);
          } else if (mapController.zoom <= 13) {
            nePanBoundary = LatLng(37.7850, -122.3853);
            swPanBoundary = LatLng(37.7555, -122.4954);
          } else if (mapController.zoom <= 14) {
            nePanBoundary = LatLng(37.805, -122.3646);
            swPanBoundary = LatLng(37.7334, -122.5122);
          } else if (mapController.zoom <= 15) {
            nePanBoundary = LatLng(37.8027, -122.3638);
            swPanBoundary = LatLng(37.7206, -122.51347);
          } else if (mapController.zoom == 16) {
            nePanBoundary = LatLng(37.8092, -122.3617);
            swPanBoundary = LatLng(37.7144, -122.5132);
          }
          // update state
          setState(() {});
        }
      });
    });
  }

  @override
  void dispose() {
    // cancel stream subscription on close
    mapEventSubscription.cancel();
    // TODO: discard controllers or remember state?
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var markers = <Marker>[];
    // sort markers by longitude (west to east)
    markerDataList.sort((a, b) => a.position.longitude.compareTo(b.position.longitude));
    // TODO: Could be outsourced to already get sorted list from stream
    for (MarkerData markerData in markerDataList) {
      // change markerSize if selected and/or active
      double selectedMarkerSize = markerSize * selectedMarkerFactor;
      double inactiveMarkerSize = markerSize * inactiveMarkerFactor;
      double adjustedMarkerSize = markerSize;
      if (markerData.selected) {
        if (markerData.active) {
          adjustedMarkerSize = selectedMarkerSize;
        }
      } else {
        if (markerData.active == false) {
          adjustedMarkerSize = inactiveMarkerSize;
        }
      }
      markers.add(
        Marker(
          width: adjustedMarkerSize,
          height: adjustedMarkerSize,
          point: markerData.position, // TODO: Adjust height for pin tip?
          builder: (ctx) => Container(
            key: Key(markerData.name),
            child: GestureDetector(
              onTap: () {
                // only do sth if marker was not already active
                if (markerData.selected == false) {
                  // set selected to true and update state
                  setState(() {
                    markerData.selected = true;
                  });

                  // move map to selected marker
                  MapLogic().animatedMapMove(
                    tickerProvider: this,
                    destLocation: markerData.position,
                    mapController: mapController,
                    corrected: true,
                  );

                  // move to correct page
                  pageController.jumpToPage(
                    markerDataList.length * 100 + markerDataList.indexOf(markerData),
                  );
                }
              },
              child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
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

                    // add agent symbol if they are at this location
                    markerData.agentIsHere
                        ? Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blueGrey,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2.5),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: maxHeight / 3.3,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                );
              }),
            ),
          ),
        ),
      );
    }
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            // set starting point and zoom limitations
            center: startingPoint,
            zoom: initialZoom,
            maxZoom: maxZoom,
            minZoom: minimalZoom,
            // set pan boundaries based on zoom level
            nePanBoundary: nePanBoundary,
            swPanBoundary: swPanBoundary,
            // necessary for changing boundaries
            slideOnBoundaries: true,
            // only allow dragging and zooming
            interactiveFlags:
                InteractiveFlag.pinchZoom | InteractiveFlag.drag | InteractiveFlag.doubleTapZoom,
          ),
          layers: [
            TileLayerOptions(
              // set background color to same grey as map background
              backgroundColor: mapBackgroundColor,
              tileProvider: const AssetTileProvider(),
              maxZoom: maxZoom,
              urlTemplate: 'assets/map/{z}/{x}/{y}.png',
            ),
            MarkerLayerOptions(markers: markers)
          ],
        ),
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 10.0,
          child: AnimatedContainer(
            onEnd: () {
              if (showMarkerDetails) {
                fullyExpanded = true;
              } else {
                fullyExpanded = false;
              }
              setState(() {});
            },
            duration: const Duration(milliseconds: 750),
            curve: Curves.fastOutSlowIn,
            height: showMarkerDetails ? (MediaQuery.of(context).size.height / 2.5) : 120.0,
            width: MediaQuery.of(context).size.width,
            child: PageView.builder(
              physics: const BouncingScrollPhysics(),
              //itemCount: markerDataList.length,
              onPageChanged: (pageIndex) {
                // set only current marker as selected and update state
                for (MarkerData marker in markerDataList) {
                  marker.selected = false;
                }
                markerDataList[pageIndex % markerDataList.length].selected = true;
                setState(() {});
                // move to marker location
                MapLogic().animatedMapMove(
                  tickerProvider: this,
                  destLocation: markerDataList[pageIndex % markerDataList.length].position,
                  mapController: mapController,
                  corrected: true,
                );
              },
              controller: pageController,
              itemBuilder: (BuildContext context, int pageIndex) {
                MarkerData currentMarker = markerDataList[pageIndex % markerDataList.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: kGlassBlurriness,
                        sigmaY: kGlassBlurriness,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        elevation: glassElevation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: glassColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  highlightColor: kAccentColor.withOpacity(0.2),
                                  splashColor: kAccentColor.withOpacity(0.2),
                                  onTap: () {
                                    if (fullyExpanded) {
                                      setState(() {
                                        showMarkerDetails = false;
                                      });
                                    } else {
                                      setState(() {
                                        showMarkerDetails = true;
                                      });

                                      // move to current marker location
                                      MapLogic().animatedMapMove(
                                        tickerProvider: this,
                                        destLocation: currentMarker.position,
                                        mapController: mapController,
                                        corrected: true,
                                      );
                                    }
                                  },
                                  child: SizedBox(
                                    height: 80.0,
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              //height: 17.0,
                                              child: Row(
                                                children: [
                                                  FittedBox(
                                                    child: Icon(
                                                      currentMarker.type.icon,
                                                      color: Colors.grey,
                                                      size: 60.0,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 5.0,
                                                  ),
                                                  FittedBox(
                                                    child: Text(
                                                      currentMarker.type.typeName,
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 60.0,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(child: Container()),
                                            //const SizedBox(height: 7.0),
                                            Expanded(
                                              flex: 3,
                                              //height: 24.0,
                                              child: FittedBox(
                                                child: Text(
                                                  currentMarker.name,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 60.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(child: Container()),
                                            //const SizedBox(height: 7.0),
                                            Expanded(
                                              flex: 2,
                                              //height: 17.0,
                                              child: FittedBox(
                                                child: Row(
                                                  children: const [
                                                    Text(
                                                      "Open" " ",
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 60.0,
                                                      ),
                                                    ),
                                                    Text(
                                                      "•" " " "8:30-22:00",
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 60.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Expanded(
                                          child: Container(),
                                        ),
                                        SizedBox(
                                          width: 50.0,
                                          child: Center(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  showMarkerDetails = !showMarkerDetails;
                                                });
                                              },
                                              child: FaIcon(
                                                showMarkerDetails
                                                    ? FontAwesomeIcons.chevronDown
                                                    : FontAwesomeIcons.chevronUp,
                                                color: Colors.grey.withOpacity(0.9),
                                                size: 22.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                showMarkerDetails & fullyExpanded
                                    ? const SizedBox(height: 15.0)
                                    : Container(),
                                showMarkerDetails & fullyExpanded
                                    ? Expanded(
                                        child: ListView(
                                          physics: const BouncingScrollPhysics(),
                                          padding: const EdgeInsets.all(0.0),
                                          children: [
                                            Text(
                                              currentMarker.infoText,
                                              textAlign: TextAlign.justify,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          width: 50,
          height: 50,
          left: 20,
          top: MediaQuery.of(context).padding.top + 20,
          child: GestureDetector(
            onTap: () {
              // find current agent locations

              List<MarkerData> agentMarkers =
                  markerDataList.where((element) => element.type == MarkerType.agent).toList();

              if (agentMarkers.isEmpty) {
                // TODO: handle no agent markers?
                print("No agent markers found?!");
              } else if (agentMarkers.length > 1) {
                // TODO: handle multiple agent markers
                print("multiple agent markers found?!");
              } else {
                // set only current marker as selected and update state
                for (MarkerData marker in markerDataList) {
                  if (marker == agentMarkers[0]) {
                    marker.selected = true;
                  } else {
                    marker.selected = false;
                  }
                }
                setState(() {});

                // move to current agent location
                MapLogic().animatedMapMove(
                  tickerProvider: this,
                  destLocation: agentMarkers[0].position,
                  mapController: mapController,
                  corrected: true,
                );

                // move to correct page
                pageController.jumpToPage(
                  markerDataList.indexOf(agentMarkers[0]),
                );
              }
            },
            child: FittedBox(
              child:
                  // TODO: change to agent picture
                  Icon(
                Icons.gps_fixed,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        )
      ],
    );
  }
}
