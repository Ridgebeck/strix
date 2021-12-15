import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:strix/config/constants.dart';

class SafeAreaGlasTop extends StatelessWidget {
  const SafeAreaGlasTop({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
            height: MediaQuery.of(context).padding.top,
          ),
        ),
      ),
    );
  }
}
