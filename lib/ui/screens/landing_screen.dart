import 'package:flutter/material.dart';
import 'package:strix/ui/screens/briefing_screen.dart';
import 'package:strix/ui/widgets/bordered_button.dart';
import 'package:strix/ui/widgets/top_icon.dart';

class LandingScreen extends StatefulWidget {
  static const String routeId = 'landing_screen';

  const LandingScreen({Key? key}) : super(key: key);

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.20,
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
                  Expanded(child: Container()),

                  FractionallySizedBox(
                    widthFactor: 0.75,
                    child: Transform(
                      transform: Matrix4.translationValues(
                          _animation.value * 500, 0.0, 0.0),
                      child: const FittedBox(
                        child: Text(
                          'welcome agent',
                          style: TextStyle(
                            fontSize: 38.0,
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
                          _animation.value * -800, 0.0, 0.0),
                      child: Text(
                        'you have been ',
                        style: TextStyle(
                          fontSize: 25.0,
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[900],
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),

                  FractionallySizedBox(
                    widthFactor: 0.75,
                    child: Transform(
                      transform: Matrix4.translationValues(
                          _animation.value * -650, 0.0, 0.0),
                      child: Text(
                        'assigned to',
                        style: TextStyle(
                          fontSize: 25.0,
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[900],
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  Expanded(child: Container()),
                  FractionallySizedBox(
                    widthFactor: 0.75,
                    child: Transform(
                      transform: Matrix4.translationValues(
                          _animation.value * 750, 0.0, 0.0),
                      child: const Text(
                        'mission',
                        style: TextStyle(
                          fontSize: 35.0,
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.75,
                    child: Transform(
                      transform: Matrix4.translationValues(
                          _animation.value * -550, 0.0, 0.0),
                      child: const FittedBox(
                        child: Text(
                          'GREEN LIGHT',
                          style: TextStyle(
                            fontSize: 42.0,
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.w900,
                            color: Colors.greenAccent,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(flex: 2, child: Container()),
                  //Expanded(child: Container()),
                  GestureDetector(
                    onTap: () {
                      _animationController.animateTo(0.0);
                      Navigator.pushReplacementNamed(
                          context, BriefingScreen.routeId);
                    },
                    child: Stack(children: const [
                      Hero(
                        tag: 'button1',
                        child: BorderedButton(
                            buttonText: 'start briefing', fontSize: 22.0),
                      ),
                      Hero(
                        tag: 'button2',
                        child: BorderedButton(
                            buttonText: 'start briefing', fontSize: 22.0),
                      ),
                    ]),
                  ),

                  Expanded(flex: 2, child: Container()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
