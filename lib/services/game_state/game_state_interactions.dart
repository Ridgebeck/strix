import 'package:flutter/cupertino.dart';
import 'game_state_abstract.dart';
import 'package:latlong2/latlong.dart';

// interaction with game document on Firestore
class GameStateInteractions implements GameState {
  // map variables and their default values
  bool isExpanded = false;
  bool showMarkerDetails = false;
  int markerTilePage = 998;
  double zoom = 15.0;
  LatLng centerPosition = LatLng(37.77155, -122.44866);
  State? mapState;
  String maximizedDataPath = "";

  // getters
  @override
  bool getIsExpanded() => isExpanded;
  @override
  bool getShowMarkerDetails() => showMarkerDetails;
  @override
  int getMarkerTilePage() => markerTilePage;
  @override
  double getZoom() => zoom;
  @override
  LatLng getCenterPosition() => centerPosition;
  @override
  State? getMapState() => mapState;

  // setters
  @override
  setIsExpanded(bool expanded) {
    isExpanded = expanded;
  }

  @override
  setShowMarkerDetails(bool show) {
    showMarkerDetails = show;
  }

  @override
  setMarkerTilePage(int page) {
    markerTilePage = page;
  }

  @override
  setZoom(double zoomLvl) {
    zoom = zoomLvl;
  }

  @override
  setCenterPosition(LatLng position) {
    centerPosition = position;
  }

  @override
  setMapState(State passedState) {
    mapState = passedState;
  }
}
