import 'package:flutter/material.dart';

class ToolsScreen extends StatelessWidget {
  final int numberOfCards = 4;

  const ToolsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 89,
          child: Container(
              //color: Colors.green,
              ),
        ),
      ],
    );
  }
}
