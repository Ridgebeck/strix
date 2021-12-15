import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:strix/config/constants.dart';
import 'package:strix/services/game_state/game_state.dart';
import 'package:strix/services/service_locator.dart';
import 'package:strix/ui/screens/picture_screen.dart';
import 'package:strix/ui/widgets/section_title.dart';

final GameState _gameState = serviceLocator<GameState>();

class ItemCarousel extends StatelessWidget {
  const ItemCarousel({
    Key? key,
    required this.itemsList,
    required this.type,
  }) : super(key: key);

  final List<String> itemsList;
  final DataType type;
  //final

  @override
  Widget build(BuildContext context) {
    bool newData = _gameState.newData.newMediaData.isThereNewData(type: type);
    print("TYPE: $type / NEW DATA: $newData");

    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * kSmallMargin),
        SectionTitle(
          title: type.details.title,
          newData: newData,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * kSmallMargin),
        CarouselSlider(
          items: itemsList
              .map((item) => GestureDetector(
                    onTap: () {
                      debugPrint("open $item in viewer");
                      Navigator.pushNamed(
                        context,
                        PictureScreen.routeId,
                        arguments: item,
                      );
                    },
                    child: Hero(
                      tag: item,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          image: DecorationImage(
                            image: AssetImage(item),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
          options: CarouselOptions(
            scrollPhysics: const BouncingScrollPhysics(),
            aspectRatio: 2.0,
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
