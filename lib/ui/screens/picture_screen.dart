import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:strix/ui/widgets/back_button.dart';
import 'package:strix/ui/widgets/safe_area_glas_top.dart';

class PictureScreen extends StatelessWidget {
  static const String routeId = 'picture_screen';
  final String pictureString;

  const PictureScreen({
    Key? key,
    required this.pictureString,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PhotoView(
          heroAttributes: PhotoViewHeroAttributes(tag: pictureString),
          minScale: PhotoViewComputedScale.contained * 1.0,
          maxScale: PhotoViewComputedScale.covered * 4.0,
          initialScale: PhotoViewComputedScale.covered * 1.1,
          imageProvider: AssetImage(pictureString),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10.0,
          left: MediaQuery.of(context).padding.left + 10.0,
          child: const BackButtonStrix(),
        ),
        const Hero(tag: "SafeAreaGlasTop", child: SafeAreaGlasTop()),
      ],
    );
  }
}
