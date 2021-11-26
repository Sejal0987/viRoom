//Splash Screen.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:microsoft_app/Screens/welcome_page.dart';

class SplashScreen extends StatefulWidget {
  final Color backgroundColor = Colors.white;
  final TextStyle styleTextUnderTheLoader = TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final splashDelay = 3;

  @override
  void initState() {
    super.initState();

    _loadWidget();
  }

  _loadWidget() async {
    var _duration = Duration(seconds: splashDelay);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() async {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => WelcomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: InkWell(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Column(
              children: [
                Expanded(
                  flex: 9,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Container(
                        child: Center(child: Image.asset('images/image1.jpg'))),
                  ),
                ),
                Text(
                  'ViRoom',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.cyan,
                      fontWeight: FontWeight.w800),
                ),
                Text(
                  'Virtual Classroom',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.cyan),
                ),
                SizedBox(
                  height: 30,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
