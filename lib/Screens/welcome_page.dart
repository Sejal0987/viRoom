//Welcome Page

import 'package:flutter/material.dart';
import '../Authentication/login.dart';
import '../widgets/myButton.dart';
import '../Authentication/signUp.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import '../Secret_keys/secret.dart';
import '../Calendar_files/calender_client.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.green, Colors.blue])),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.black, Colors.cyan])),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 140),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Hero(
                      tag: 'logo',
                      child: Image.asset(
                        'images/image1.jpg',
                        height: 90,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'ViRoom',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 25.0,
                        color: Colors.cyan,
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),

                    //Sign Up Button
                    RoundButton(
                      text: 'Sign up',
                      onPressed: () async {
                        //Get Google calendar access & create new Oauth Client.
                        String ls;
                        var _clientID = new ClientId(Secret.getId(), "");
                        const _scopes = const [cal.CalendarApi.CalendarScope];
                        await clientViaUserConsent(_clientID, _scopes, prompt)
                            .then((AuthClient client) async {
                          print(_scopes);
                          CalendarClient.calendar = cal.CalendarApi(client);
                          await CalendarClient.calendar.calendarList
                              .list()
                              .then((value) {
                            ls = value.items[0].id;
                          });
                        }).then((value) {
                          print(ls);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      RegistrationScreen(
                                        useremail: ls,
                                      )));
                        });
                      },
                      color: Colors.cyan.withOpacity(0.8),
                    ),

                    SizedBox(
                      height: 10,
                    ),

                    //Login Button
                    RoundButton(
                      text: 'Log in',
                      onPressed: () async {
                        //Get Google calendar access.
                        String ls;
                        var _clientID = new ClientId(Secret.getId(), "");
                        const _scopes = const [cal.CalendarApi.CalendarScope];
                        await clientViaUserConsent(_clientID, _scopes, prompt)
                            .then((AuthClient client) async {
                          CalendarClient.calendar = cal.CalendarApi(client);
                          print(_scopes);
                          await CalendarClient.calendar.calendarList
                              .list()
                              .then((value) {
                            print(value.toJson());
                            ls = value.items[0].id;
                          });
                        }).then((value) {
                          print(ls);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      LoginScreen(
                                        useremail: ls,
                                      )));
                        });
                      },
                      color: Colors.cyan.withOpacity(0.8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

void prompt(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
