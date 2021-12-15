import 'package:flutter/material.dart';
import 'package:strix/config/constants.dart';

class BackButtonStrix extends StatelessWidget {
  const BackButtonStrix({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      mini: true,
      elevation: kGlassElevation,
      backgroundColor: kGlassColor,
      splashColor: kSplashColor,
      onPressed: () {
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          height: 100.0,
          width: 100.0,
          decoration: BoxDecoration(
            color: Colors.grey[700]!.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.navigate_before_sharp,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
