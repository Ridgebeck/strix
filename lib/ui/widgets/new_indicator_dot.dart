import 'package:flutter/cupertino.dart';
import 'package:strix/config/constants.dart';

class NewIndicatorDot extends StatelessWidget {
  const NewIndicatorDot({
    Key? key,
    required this.newData,
  }) : super(key: key);

  final bool newData;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: -10.0,
      top: -10.0,
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
