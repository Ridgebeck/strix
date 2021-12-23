import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/static_data.dart';
import 'package:strix/config/constants.dart';
import 'package:strix/ui/screens/picture_screen.dart';
import 'package:strix/ui/widgets/section_title.dart';

import 'new_indicator_dot.dart';

class ItemCarousel extends StatelessWidget {
  const ItemCarousel({
    Key? key,
    required this.itemsList,
    required this.type,
  }) : super(key: key);

  final List<DataItem> itemsList;
  final DataType type;
  //final

  @override
  Widget build(BuildContext context) {
    // check if there are any new items in category
    bool newItemInCategory = itemsList.indexWhere((element) => element.isNew) == -1 ? false : true;
    //reverse list to show newest items first
    List<DataItem> reversedItemsList = itemsList.reversed.toList();

    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * kSmallMargin),
        SectionTitle(
          title: type.details.title,
          newData: newItemInCategory,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * kSmallMargin),
        CarouselSlider(
          items: reversedItemsList
              .map((item) => GestureDetector(
                    onTap: () {
                      item.isNew = false;
                      debugPrint("open $item in viewer");
                      Navigator.pushNamed(
                        context,
                        PictureScreen.routeId,
                        arguments: item.fileName,
                      );
                    },
                    child: Hero(
                      tag: item.fileName,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                image: DecorationImage(
                                  image: AssetImage(item.fileName),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            NewIndicatorDot(
                              newData: item.isNew,
                              isInside: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
              .toList(),
          options: CarouselOptions(
            scrollPhysics: const BouncingScrollPhysics(),
            aspectRatio: 1.8,
            enlargeCenterPage: true,
            enableInfiniteScroll: false,
            initialPage: 0,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * kLargeMargin),
      ],
    );
  }
}
