//Login Screen. Allows already existing users to login to the app using their password.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:microsoft_app/widgets/myButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Screens/Class_list/schedulerList.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:microsoft_app/widgets/my_TextField.dart';

class LoginScreen extends StatefulWidget {
  String useremail;
  LoginScreen({this.useremail});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String password;
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.black, Colors.cyan])),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: 40.0,
                ),
                //Password TextField.
                MyTextField(
                  obscureText: true,
                  onChanged: (value) {
                    password = value;
                  },
                  hintText: 'Enter your password.',
                  labelText: 'Password',
                ),

                SizedBox(
                  height: 24.0,
                ),

                //Logging In already existing user.
                RoundButton(
                    color: Colors.cyan,
                    text: 'Log In',
                    onPressed: () async {
                      setState(() {});

                      try {
                        final user = await _auth.signInWithEmailAndPassword(
                            email: widget.useremail, password: password);
                        if (user != null) {
                          setState(() {});

                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ClassList()));
                        }
                        setState(() {});
                      } catch (e) {
                        if (widget.useremail == null) {
                          Alert(
                            context: context,
                            type: AlertType.error,
                            title: "ALERT",
                            desc:
                                "Problem extracting mail. Please open app again to grant permissions.",
                            buttons: [
                              DialogButton(
                                child: Text(
                                  "Close",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                width: 120,
                              )
                            ],
                          ).show();
                        } else {
                          Alert(
                            context: context,
                            type: AlertType.error,
                            title: "ALERT",
                            desc: "${e.toString()}",
                            buttons: [
                              DialogButton(
                                child: Text(
                                  "Close",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                width: 120,
                              )
                            ],
                          ).show();
                        }
                        setState(() {});
                        print(e);
                      }
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
