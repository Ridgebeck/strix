import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/room.dart';
import 'package:strix/ui/widgets/item_carousel.dart';

class DataScreen extends StatefulWidget {
  final AvailableAssetEntry assets;

  const DataScreen({
    Key? key,
    required this.assets,
  }) : super(key: key);

  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  @override
  Widget build(BuildContext context) {
    AvailableAssetEntry assets = widget.assets;

    if (assets.data == null) {
      // TODO: nicer placeholder widget
      return const Center(child: Text("No data received yet."));
    } else {
      // create empty widget list
      List<Widget> dataPageCarousels = [];
      // go through all item categories
      assets.data!.toMap().forEach((itemDataType, itemData) {
        if (itemData != null) {
          // create string list
          List<String> stringList = [];
          for (String itemString in itemData) {
            stringList.add(itemDataType.folderPath + itemString);
          }
          // reverse order
          stringList = stringList.reversed.toList();
          // add item carousel to list
          dataPageCarousels.add(ItemCarousel(
            itemsList: stringList,
            dataDetails: itemDataType,
          ));
        }
      });

      // display carousel list in scrollable list view
      return ListView(
        physics: const BouncingScrollPhysics(),
        children: dataPageCarousels,
      );
    }
  }
}
