// Using an abstract class like this allows to swap concrete implementations.
// This is useful for separating architectural layers.
// It also makes testing and development easier because you can provide
// a mock implementation or fake data.
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';

abstract class GameState {
  // check if menu is fully expanded
  bool getIsExpanded();
  // check if menu is folded
  bool getShowMarkerDetails();
  // return currently selected page number
  int getMarkerTilePage();
  // return zoom level
  double getZoom();
  // get center position of map
  LatLng getCenterPosition();
  // get the State of the map page
  State? getMapState();

  // set menu expanded variable
  setIsExpanded(bool isExpanded);
  // set menu expanded variable
  setShowMarkerDetails(bool show);
  // set currently selected page number
  setMarkerTilePage(int page);
  // set zoom level
  setZoom(double zoomLvl);
  // set center position of map
  setCenterPosition(LatLng position);
  // set state of map page
  setMapState(State mapState);
}
