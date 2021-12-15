import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:strix/config/route_generator.dart';
import 'package:strix/services/service_locator.dart';
import 'package:strix/services/authorization/authorization_abstract.dart';
import 'package:strix/ui/screens/landing_screen.dart';
//import 'package:strix/ui/screens/video_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // fix app orientation to portrait mode
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
  ));

  // initialize all services (database, auth, storage)
  await setupServices();

  // sign in user anonymously
  await serviceLocator<Authorization>().signInUserAnonymous();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Strix',
      initialRoute: LandingScreen.routeId, //VideoBackground.routeId, //MainGameScreen.route_id,
      onGenerateRoute: RouteGenerator.generateRoute,
      theme: ThemeData(
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,

        brightness: Brightness.dark,
        primaryColor: Colors.red,
        accentColor: Colors.cyan,
        splashColor: Colors.cyan,
        //textTheme: ,
        scaffoldBackgroundColor: Colors.grey[900], // only call screen??

        dialogBackgroundColor: Colors.red,

        //fontFamily:
        //backgroundColor: Colors.red,
      ),
    );
  }
}
