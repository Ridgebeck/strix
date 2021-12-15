import 'package:flutter/cupertino.dart';
import 'package:strix/ui/widgets/new_indicator_dot.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    Key? key,
    required this.title,
    this.newData = false,
  }) : super(key: key);
  final String title;
  final bool newData;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.033,
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            FittedBox(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 100.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            NewIndicatorDot(newData: newData),
          ],
        ),
      ),
    );
  }
}
