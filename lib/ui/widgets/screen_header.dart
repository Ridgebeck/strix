// import 'package:flutter/material.dart';
// import 'package:flutter_neumorphic/flutter_neumorphic.dart';
// import 'package:strix/config/constants.dart';
//
// class ScreenHeader extends StatelessWidget {
//   ScreenHeader({required this.title, required this.iconData});
//   final String title;
//   final IconData iconData;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Column(
//         children: [
//           Expanded(child: Container()),
//           Expanded(
//             flex: 3,
//             child: Row(
//               children: [
//                 Expanded(flex: 5, child: Container()),
//                 FittedBox(
//                   child: NeumorphicIcon(
//                     iconData,
//                     // size is defined by FittedBox dimensions
//                     size: 60.0, // max size
//                     style: NeumorphicStyle(
//                       color: kBackgroundColorLight,
//                       depth: 1.5,
//                       intensity: 1.0,
//                       shadowDarkColor: Colors.blueGrey[200],
//                     ),
//                   ),
//                 ),
//                 Expanded(flex: 1, child: Container()),
//                 Column(
//                   children: [
//                     Expanded(flex: 1, child: Container()),
//                     Expanded(
//                       flex: 8,
//                       child: Container(
//                         constraints:
//                             BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
//                         child: FittedBox(
//                           child: NeumorphicText(
//                             title.toUpperCase(),
//                             //headerText.toUpperCase(),
//                             textAlign: TextAlign.start,
//                             style: NeumorphicStyle(
//                               depth: 1.0,
//                               intensity: 1.0,
//                               color: kBackgroundColorLight,
//                               shadowDarkColor: Colors.blueGrey[300],
//                             ),
//                             textStyle: NeumorphicTextStyle(
//                               fontSize: 35.0,
//                               //fontWeight: FontWeight.bold,
//                               //fontFamily: 'Orbitron',
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(flex: 1, child: Container()),
//                   ],
//                 ),
//                 Expanded(flex: 5, child: Container()),
//               ],
//             ),
//           ),
//           Expanded(child: Container()),
//         ],
//       ),
//     );
//   }
// }
