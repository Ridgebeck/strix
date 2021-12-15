import 'package:flutter/material.dart';
import 'package:strix/business_logic/classes/call.dart';
import 'package:strix/business_logic/classes/person.dart';
import 'package:strix/ui/screens/briefing_screen.dart';
import 'package:strix/ui/screens/call_screen.dart';
import 'package:strix/ui/screens/icoming_call_screen.dart';
import 'package:strix/ui/screens/join_room_screen.dart';
import 'package:strix/ui/screens/landing_screen.dart';
import 'package:strix/ui/screens/picture_screen.dart';
import 'package:strix/ui/screens/profile_screen.dart';
import 'package:strix/ui/screens/start_join_screen.dart';
import 'package:strix/ui/screens/video_background.dart';
import 'package:strix/ui/screens/waiting_room_screen.dart';
import 'package:strix/ui/screens/main_game_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final arguments = settings.arguments;

    switch (settings.name) {
      case VideoBackground.routeId:
        return MaterialPageRoute(
          builder: (_) => const VideoBackground(),
        );

      case LandingScreen.routeId:
        return PageRouteBuilder(
          opaque: false,
          pageBuilder: (context, _, __) {
            return (const LandingScreen());
          },
          transitionDuration: const Duration(milliseconds: 1400),
        );

      case BriefingScreen.routeId:
        return PageRouteBuilder(
          opaque: false,
          pageBuilder: (context, animation, secondaryAnimation) {
            return const BriefingScreen();
          },
          transitionDuration: const Duration(milliseconds: 1400),
        );

      case StartJoinScreen.routeId:
        return PageRouteBuilder(
          opaque: false,
          pageBuilder: (context, _, __) {
            return (const StartJoinScreen());
          },
        );

      case WaitingRoomScreen.routeId:
        if (arguments is String) {
          return PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) {
              return WaitingRoomScreen(roomID: arguments);
            },
            transitionDuration: const Duration(milliseconds: 1400),
          );
        }
        return _errorRoute();

      case JoinRoomScreen.routeId:
        return PageRouteBuilder(
          opaque: false,
          pageBuilder: (context, _, __) {
            return (const JoinRoomScreen());
          },
          transitionDuration: const Duration(milliseconds: 1400),
        );

      case MainGameScreen.routeId:
        if (arguments is String) {
          return PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, _, __) {
              return (MainGameScreen(
                roomID: arguments,
              ));
            },
          );
        }
        return _errorRoute();

      case PictureScreen.routeId:
        if (arguments is String) {
          return MaterialPageRoute(
            builder: (_) => PictureScreen(
              pictureString: arguments,
            ),
          );
        }
        return _errorRoute();

      case ProfileScreen.routeId:
        if (arguments is Person) {
          return MaterialPageRoute(
            builder: (_) => ProfileScreen(
              person: arguments,
            ),
          );
        }
        return _errorRoute();

      case IncomingCallScreen.routeId:
        if (arguments is Call) {
          return MaterialPageRoute(
            builder: (_) => IncomingCallScreen(
              call: arguments,
            ),
          );
        }
        return _errorRoute();

      case CallScreen.routeId:
        if (arguments is Call) {
          return MaterialPageRoute(
            builder: (_) => CallScreen(
              call: arguments,
            ),
          );
        }
        return _errorRoute();

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}

class FadeRoute extends PageRouteBuilder {
  final Widget? page;
  FadeRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page!,
          opaque: false,
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
}
