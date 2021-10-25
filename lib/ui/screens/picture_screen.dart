import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PictureScreen extends StatelessWidget {
  static const String routeId = 'picture_screen';
  final String pictureString;

  const PictureScreen({
    Key? key,
    required this.pictureString,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.black,
      body: Stack(children: [
        PhotoView(
          minScale: PhotoViewComputedScale.contained * 1.0,
          maxScale: PhotoViewComputedScale.covered * 2.5,
          initialScale: PhotoViewComputedScale.covered * 1.0,
          imageProvider: AssetImage('assets/data/' + pictureString),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10.0,
          left: MediaQuery.of(context).padding.left + 10.0,
          child: FloatingActionButton(
            mini: true,
            //backgroundColor: kAccentColor,
            //splashColor: kBackgroundColorLight,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.navigate_before_sharp,
              color: Colors.black,
            ),
          ),
        ),
      ]),
    );
  }
}
