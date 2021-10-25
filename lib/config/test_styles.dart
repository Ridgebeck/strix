import 'dart:math';

import 'package:flutter/material.dart';

enum PhoneSize { small, medium, large }

class TextStyles {
  late TextStyle headerTextStyle;
  late TextStyle stdTextStyle;
  late TextStyle boldTextStyle;

  TextStyles({required BuildContext context}) {
    Size s = MediaQuery.of(context).size;
    double diagonal = sqrt((s.width * s.width) + (s.height * s.height));
    //print(diagonal);

    PhoneSize phoneSize = diagonal > 850.0
        ? PhoneSize.large
        : diagonal > 750.0
            ? PhoneSize.medium
            : PhoneSize.small;

    this.headerTextStyle = TextStyle(
      color: Colors.greenAccent,
      fontFamily: 'Raleway',
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      fontSize: phoneSize == PhoneSize.large
          ? 25.0
          : phoneSize == PhoneSize.medium
              ? 22.0
              : 19.0,
    );

    this.stdTextStyle = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w400,
      fontSize: phoneSize == PhoneSize.large
          ? 22.0
          : phoneSize == PhoneSize.medium
              ? 20.0
              : 17.0,
    );

    this.boldTextStyle = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w700,
      fontSize: phoneSize == PhoneSize.large
          ? 22.0
          : phoneSize == PhoneSize.medium
              ? 20.0
              : 17.0,
    );
  }
}
