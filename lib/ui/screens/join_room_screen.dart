import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:strix/business_logic/logic/join_room_logic.dart';
import 'package:strix/ui/widgets/bordered_button.dart';
import 'package:strix/ui/widgets/top_icon.dart';

import 'briefing_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  static const String routeId = 'join_room_screen';

  const JoinRoomScreen({Key? key}) : super(key: key);

  @override
  _JoinRoomScreenState createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  late Animation _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.width * 0.80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Hero(
                          tag: 'strixIcon',
                          child: TopIcon(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(flex: 3, child: Container()),
                  FractionallySizedBox(
                    widthFactor: 0.75,
                    child: Transform(
                      transform: Matrix4.translationValues(
                          _animation.value * -950, 0.0, 0.0),
                      child: const FittedBox(
                        child: Text(
                          'Please enter Session ID',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: Container()),
                  FractionallySizedBox(
                    widthFactor: 0.75,
                    child: Transform(
                      transform: Matrix4.translationValues(
                          _animation.value * -1250, 0.0, 0.0),
                      child: TextField(
                        controller: _textController,
                        inputFormatters: [
                          UpperCaseTextFormatter(),
                        ],
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 5.0,
                        ),
                        decoration: InputDecoration(
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          hintText: 'e.g. XFMIGT',
                          hintStyle: TextStyle(
                            fontSize: 22,
                            letterSpacing: 2.0,
                            fontStyle: FontStyle.italic,
                            color: Colors.blueGrey[900],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(flex: 3, child: Container()),
                  Row(
                    children: [
                      Expanded(child: Container()),
                      GestureDetector(
                        onTap: () {
                          _animationController.animateTo(0.0);
                          Navigator.of(context)
                              .pushReplacementNamed(BriefingScreen.routeId);
                        },
                        child: const Hero(
                          tag: 'button1',
                          child: Material(
                            color: Colors.transparent,
                            child: BorderedButton(
                              buttonText: 'back',
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                      Expanded(child: Container()),
                      GestureDetector(
                        onTap: () async {
                          if (_textController.text.isNotEmpty) {
                            await JoinRoomLogic().joinRoom(
                              roomID: _textController.text,
                              context: context,
                              animationController: _animationController,
                            );
                          }
                        },
                        child: const Hero(
                          tag: 'button2',
                          child: Material(
                            color: Colors.transparent,
                            child: BorderedButton(
                              buttonText: 'join',
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                      Expanded(child: Container()),
                    ],
                  ),
                  Expanded(flex: 3, child: Container()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
