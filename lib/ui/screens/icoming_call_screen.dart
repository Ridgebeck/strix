import 'package:flutter/material.dart';
// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:strix/business_logic/classes/call.dart';
import 'package:strix/business_logic/classes/room.dart';
import 'package:wakelock/wakelock.dart';
import 'call_screen.dart';

class IncomingCallScreen extends StatefulWidget {
  static const String routeId = 'incoming_call_screen';

  final Room room;
  const IncomingCallScreen({Key? key, required this.room}) : super(key: key);

  @override
  _IncomingCallScreenState createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  late Call call;

  @override
  void initState() {
    // enable wakelock to prevent screen turning off
    Wakelock.enable();
    // find current progress entry
    AvailableAssetEntry currentEntry = widget.room.availableAssets.singleWhere(
        (element) => element.entryName == widget.room.gameProgress);
    // get call of current entry
    call = currentEntry.call!; //has been null checked on main screen
    //FlutterRingtonePlayer.playRingtone(asAlarm: true);
    super.initState();
  }

  @override
  void dispose() {
    //FlutterRingtonePlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        //backgroundColor: kBackgroundColorLight,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(flex: 4, child: Container()),
              Expanded(
                flex: 3,
                child: FractionallySizedBox(
                  widthFactor: 0.75,
                  child: FittedBox(
                    child: Text(
                      'incoming call'.toUpperCase(),
                      style: const TextStyle(fontSize: 75.0),
                    ),
                  ),
                ),
              ),
              Expanded(child: Container()),
              const Expanded(
                flex: 2,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: FittedBox(
                    child: Text(
                      'via secured line',
                      style: TextStyle(fontSize: 75.0),
                    ),
                  ),
                ),
              ),
              Expanded(flex: 3, child: Container()),
              Expanded(
                flex: 20,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return MirrorAnimation<double>(
                        tween: Tween<double>(
                          begin: constraints.maxHeight,
                          end: 0.96 * constraints.maxHeight,
                        ),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, child, animatedSize) {
                          return Center(
                            child: Container(
                              height: animatedSize,
                              width: animatedSize,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(500.0),
                                image: DecorationImage(
                                  image: AssetImage(
                                      'assets/profile_pictures/${call.person.profileImage}'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        });
                  },
                ),
              ),
              Expanded(flex: 3, child: Container()),
              Expanded(
                flex: 3,
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: FittedBox(
                    child: Text(
                      (call.person.firstName + ' ' + call.person.lastName)
                          .toUpperCase(),
                      style: const TextStyle(fontSize: 75.0),
                    ),
                  ),
                ),
              ),
              Expanded(child: Container()),
              Expanded(
                flex: 2,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: FittedBox(
                    child: Text(
                      call.person.title,
                      style: const TextStyle(fontSize: 20.0),
                    ),
                  ),
                ),
              ),
              Expanded(flex: 6, child: Container()),
              Expanded(
                flex: 5,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CallButton(
                          iconData: Icons.call,
                          iconColor: Colors.green,
                          onTapFunction: () {
                            //FlutterRingtonePlayer.stop();
                            Navigator.of(context).pushReplacementNamed(
                                CallScreen.routeId,
                                arguments: widget.room);
                          },
                        ),
                        CallButton(
                          iconData: Icons.call_end,
                          iconColor: Colors.red,
                          onTapFunction: () {},
                        ),
                      ],
                    );
                  },
                ),
              ),
              Expanded(flex: 3, child: Container()),
            ],
          ),
        ),
      ),
    );
  }
}

class CallButton extends StatelessWidget {
  final IconData iconData;
  final Color iconColor;
  final Function onTapFunction;
  const CallButton({
    Key? key,
    required this.iconData,
    required this.iconColor,
    required this.onTapFunction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => onTapFunction(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: constraints.maxHeight,
              width: constraints.maxHeight,
              child: FractionallySizedBox(
                heightFactor: 0.65,
                child: FittedBox(
                  child: Icon(
                    iconData,
                    size: 50.0,
                    color: iconColor,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
