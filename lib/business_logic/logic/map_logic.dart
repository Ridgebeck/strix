import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapLogic {
  // animate move from current to target location on map
  void animatedMapMove({
    required TickerProvider tickerProvider,
    required MapController mapController,
    required LatLng destLocation,
    //required double destZoom,
    bool corrected = false,
  }) {
    // use current zoom by default
    double destZoom = mapController.zoom;

    // correct position if required
    if (corrected) {
      destLocation = _correctedPosition(
        mapController: mapController,
        position: destLocation,
      );
    }

    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final _latTween =
        Tween<double>(begin: mapController.center.latitude, end: destLocation.latitude);
    final _lngTween =
        Tween<double>(begin: mapController.center.longitude, end: destLocation.longitude);
    final _zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    var controller =
        AnimationController(duration: const Duration(milliseconds: 1500), vsync: tickerProvider);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)),
          _zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  LatLng _correctedPosition({
    required MapController mapController,
    required LatLng position,
  }) {
    // based on max zoom lvl 18
    double delta = 0.000625;
    double adjustment = delta;
    double base = 2;
    double adder;

    for (double x = 1; x < 18 - mapController.zoom; x++) {
      if (x < 18 - mapController.zoom - 1) {
        adder = pow(base, x) * delta;
      } else {
        adjustment = adjustment + delta;
        if (((18 - mapController.zoom) % 1) == 0) {
          adder = pow(base, x) * delta;
        } else {
          adder = ((18 - mapController.zoom) % 1) * pow(base, x) * delta;
        }
      }
      adjustment = adjustment + adder;
    }
    return LatLng(
      position.latitude - adjustment,
      position.longitude,
    );
  }
}
