import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:strix/business_logic/classes/marker.dart';
import 'package:strix/business_logic/classes/static_data.dart';
import 'package:latlong2/latlong.dart';
import 'package:strix/business_logic/logic/map_logic.dart';
import 'package:strix/config/constants.dart';
import 'package:strix/services/game_state/game_state.dart';
import 'package:strix/services/service_locator.dart';
import 'package:strix/ui/widgets/safe_area_glas_top.dart';
import 'package:tuple/tuple.dart';

// TODO: import starting position or calculate from map
// set Derek's Apartment as starting point
LatLng nePanBoundary = LatLng(37.82, -122.36);
LatLng swPanBoundary = LatLng(37.69, -122.53);

// TODO: get values from map settings
const double minimalZoom = 12.0;
const double maxZoom = 16.0;

const mapBackgroundColor = Color(0xFF212121);
const int mapAnimTimeMs = 1500;

class GameMapScreen extends StatefulWidget {
  final MapEntry? mapData;

  const GameMapScreen({
    Key? key,
    required this.mapData,
  }) : super(key: key);

  @override
  GameMapScreenState createState() => GameMapScreenState();
}

class GameMapScreenState extends State<GameMapScreen> with TickerProviderStateMixin {
  final GameState _gameState = serviceLocator<GameState>();

  // controllers and stream subscription
  late final MapController mapController;
  late final PageController pageController;
  late final StreamSubscription<MapEvent> mapEventSubscription;

  @override
  void initState() {
    super.initState();

    // set expanded variable to same state as info tile state on startup
    _gameState.isExpanded = _gameState.showMarkerDetails;

    // initialize controllers
    mapController = MapController();
    pageController = PageController(
      viewportFraction: 0.90,
      initialPage: _gameState.markerTilePage,
    );

    // when map controller is ready
    mapController.onReady.then((_) {
      // start stream subscription to catch controller events
      mapEventSubscription = mapController.mapEventStream.listen((event) {
        // after every tap-zoom or move event
        if (event is MapEventDoubleTapZoomEnd || event is MapEventMoveEnd) {
          // save current center position
          _gameState.centerPosition = mapController.center;
          // save current current zoom level
          _gameState.zoom = mapController.zoom;
        }
      });
    });

    // set map state so that position animation can update screen
    _gameState.mapState = this;
  }

  @override
  void dispose() {
    mapEventSubscription.cancel();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("BUILDING MAP SCREEN");

    MapEntry mapData = widget.mapData!;

    // create empty lists for markers and polylines
    List<Marker> markers = [];
    List<Polyline> polylines = [];

    // check if map data is null
    if (mapData.markerList.isEmpty) {
      // TODO: handle no map data?
      debugPrint("NO MAP DATA");
    } else {
      // create lists of markers and polylines (paths)
      Tuple2<List<Marker>, List<Polyline>> markerPolyLists = MapLogic().createMarkersAndPolylines(
        mapData: mapData,
        pageController: pageController,
      );
      markers = markerPolyLists.item1;
      polylines = markerPolyLists.item2;
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            // set starting point and zoom limitations
            center: _gameState.centerPosition,
            zoom: _gameState.zoom,
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
            PolylineLayerOptions(polylines: polylines),
            MarkerLayerOptions(markers: markers),
          ],
        ),
        // don't show marker info tiles if mapData is null
        // or marker list is null or empty
        // prevents errors while loading / changing data
        mapData.markerList.isEmpty
            ? Container()
            : Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 10.0,
                child: AnimatedContainer(
                  onEnd: () {
                    _gameState.showMarkerDetails
                        ? _gameState.isExpanded = true
                        : _gameState.isExpanded = false;
                    setState(() {});
                  },
                  duration: const Duration(milliseconds: 750),
                  curve: Curves.fastOutSlowIn,
                  height: _gameState.showMarkerDetails
                      ? (MediaQuery.of(context).size.height / 2.5)
                      : 120.0,
                  width: MediaQuery.of(context).size.width,
                  child: PageView.builder(
                    physics: const BouncingScrollPhysics(),
                    // TODO: Show no pages if only one entry
                    //itemCount: mapData!.markerList!.length == 1 ? 1 : null,
                    onPageChanged: (pageIndex) {
                      // save current page
                      _gameState.markerTilePage = pageIndex;

                      // set only current marker as selected and update state
                      for (MarkerData marker in mapData.markerList) {
                        marker.isSelected = false;
                      }
                      // flag as selected
                      mapData.markerList[pageIndex % mapData.markerList.length].isSelected = true;
                      // remove new flag
                      mapData.markerList[pageIndex % mapData.markerList.length].isNew = false;

                      // check if there are no new markers left
                      _gameState.newData.newMapDataNotifier.value = mapData.hasNewMarkers();

                      // move camera to specified location
                      const MovingAnimation().createState().animatedMapMove(
                            mapController: mapController,
                            destLocation:
                                mapData.markerList[pageIndex % mapData.markerList.length].position,
                            corrected: true,
                          );
                    },
                    controller: pageController,
                    itemBuilder: (BuildContext context, int pageIndex) {
                      MarkerData currentMarker =
                          mapData.markerList[pageIndex % mapData.markerList.length];
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
                              elevation: kGlassElevation,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: kGlassColor,
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
                                          if (_gameState.isExpanded) {
                                            setState(() {
                                              _gameState.showMarkerDetails = false;
                                            });
                                          } else {
                                            setState(() {
                                              _gameState.showMarkerDetails = true;
                                            });

                                            // move to specified location
                                            const MovingAnimation().createState().animatedMapMove(
                                                  mapController: mapController,
                                                  destLocation: currentMarker.position,
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
                                                        _gameState.showMarkerDetails =
                                                            !_gameState.showMarkerDetails;
                                                      });
                                                    },
                                                    child: FaIcon(
                                                      _gameState.showMarkerDetails
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
                                      _gameState.showMarkerDetails & _gameState.isExpanded
                                          //fullyExpanded
                                          ? const SizedBox(height: 15.0)
                                          : Container(),
                                      _gameState.showMarkerDetails & _gameState.isExpanded
                                          //fullyExpanded
                                          ? Expanded(
                                              child: ListView(
                                                physics: const BouncingScrollPhysics(),
                                                padding: const EdgeInsets.all(0.0),
                                                children: [
                                                  Text(
                                                    currentMarker.infoText ?? "",
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

        // don't show agent locator if mapData is null
        // or personMarkerList is empty
        // prevents errors while loading / changing data
        mapData == null
            ? Container()
            : mapData.personMarkerList.isEmpty
                ? Container()
                : Positioned(
                    left: 15,
                    top: MediaQuery.of(context).padding.top + 15,
                    child: Column(
                      children: List.generate(mapData.personMarkerList.length, (index) {
                        PersonMarkerData personMarker = mapData.personMarkerList[index];
                        return GestureDetector(
                          onTap: () {
                            List<MarkerData> agentLocations = mapData.markerList
                                .where((list) => list.personsHere.contains(personMarker.person))
                                .toList();

                            if (agentLocations.isEmpty) {
                              // move to current agent location
                              const MovingAnimation().createState().animatedMapMove(
                                    mapController: mapController,
                                    destLocation: personMarker.currentPosition,
                                    corrected: true,
                                    destZoom: 16.0,
                                  );
                            } else {
                              if (pageController.page ==
                                  mapData.markerList.length * 100 +
                                      mapData.markerList.indexOf(agentLocations[0])) {
                                // move to current agent location
                                const MovingAnimation().createState().animatedMapMove(
                                      mapController: mapController,
                                      destLocation: agentLocations[0].position,
                                      corrected: true,
                                      destZoom: 16.0,
                                    );
                              } else {
                                // move to correct page
                                // this triggers also a map move
                                pageController.jumpToPage(
                                  mapData.markerList.length * 100 +
                                      mapData.markerList.indexOf(agentLocations[0]),
                                );
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Stack(
                              children: [
                                Icon(
                                  Icons.gps_fixed,
                                  color: Colors.white.withOpacity(0.5),
                                  size: 60.0,
                                ),
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: AssetImage('assets/profile_pictures/' +
                                              personMarker.person.profileImage),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      width: 35.0,
                                      height: 35.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
        const SafeAreaGlasTop(),
      ],
    );
  }
}
