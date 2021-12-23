import 'package:flutter/cupertino.dart';
import 'package:strix/config/constants.dart';

class NewIndicatorDot extends StatelessWidget {
  const NewIndicatorDot({
    Key? key,
    required this.newData,
    this.isInside = false,
    this.isLeft = false,
  }) : super(key: key);

  final bool newData;
  final bool isInside;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: isLeft
          ? isInside
              ? 5.0
              : -8.0
          : null,
      right: isLeft
          ? null
          : isInside
              ? 5.0
              : -8.0,
      top: isInside ? 5.0 : -8.0,
      child: Visibility(
        visible: //tabController.index == index ? false : false,
            newData ? true : false,
        child: Container(
          width: 10.0,
          height: 10.0,
          decoration: BoxDecoration(
            color: kAccentColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
    );
  }
}
