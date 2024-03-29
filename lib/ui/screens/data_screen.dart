import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/static_data.dart';
import 'package:strix/config/constants.dart';
import 'package:strix/ui/widgets/item_carousel.dart';
import 'package:strix/ui/widgets/safe_area_glas_top.dart';

class DataScreen extends StatelessWidget {
  final DataEntry data;
  final bool hasInsta;

  const DataScreen({
    Key? key,
    required this.data,
    required this.hasInsta,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("BUILDING DATA SCREEN");

    // check if data is null
    if (data.isEmpty()) {
      // TODO: nicer placeholder widget
      return const Center(child: Text("no data received yet"));
    }
    // create empty widget list
    List<Widget> dataPageCarousels = [];

    // go through all data types
    for (DataType type in DataType.values) {
      // show social data only when group has no insta
      if (type != DataType.social || type == DataType.social && hasInsta == false) {
        if (data.getData(type: type).isNotEmpty) {
          // add item carousel to list
          dataPageCarousels.add(ItemCarousel(
            itemsList: data.getData(type: type),
            type: type,
          ));
        }
      }
    }

    // display carousel list in scrollable list view
    return Stack(
      children: [
        ListView(
          physics: const BouncingScrollPhysics(),
          children: dataPageCarousels,
        ),
        const Hero(tag: "SafeAreaGlasTop", child: SafeAreaGlasTop()),
      ],
    );
  }
}
