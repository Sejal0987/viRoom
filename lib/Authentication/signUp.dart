//Sign Up Screen - Create new user to database.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/myButton.dart';
import 'package:microsoft_app/db/user.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../Screens/Class_list/schedulerList.dart';
import 'package:microsoft_app/widgets/my_ListTile.dart';
import 'package:microsoft_app/widgets/my_TextField.dart';

class RegistrationScreen extends StatefulWidget {
  String useremail;
  RegistrationScreen({this.useremail});
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String password, name, category = "";
  final _auth = FirebaseAuth.instance;
  UserServices _userServices = UserServices();
  String vac;
  int dose = 0;
  final List<String> vacStatus = <String>['Yes', 'No'];
  @override
  Widget build(BuildContext context) {
    //change value of category dropdown.
    valueChanged(e) {
      setState(() {
        dose = e;
      });
    }

    //change value of vaccination status dropdown.
    valueChanged1(e) {
      setState(() {
        category = e;
      });
    }

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
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Center(
              child: Container(
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(
                          height: 20.0,
                        ),

                        //Name TextField Starts.
                        MyTextField(
                          onChanged: (value) {
                            name = value;
                          },
                          labelText: 'Name',
                          hintText: 'Enter your full name.',
                          obscureText: false,
                        ),

                        SizedBox(
                          height: 15.0,
                        ),

                        //Password TextField.
                        MyTextField(
                          onChanged: (value) {
                            password = value;
                          },
                          hintText: 'Enter your password.',
                          labelText: 'Password',
                          obscureText: true,
                        ),

                        SizedBox(
                          height: 15.0,
                        ),

                        //Category Selection.
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              border: Border.all(color: Colors.cyan),
                              borderRadius: BorderRadius.circular(4)),
                          child: Row(
                            children: [
                              Expanded(
                                child: MyListTile(
                                  title: 'Student',
                                  color: category == "student"
                                      ? Colors.white
                                      : Colors.black54,
                                  value: "student",
                                  groupValue: category,
                                  onChanged: (e) => valueChanged1(e),
                                  fontSize: 0.016 *
                                      MediaQuery.of(context).size.height,
                                ),
                              ),
                              Expanded(
                                  child: MyListTile(
                                title: 'Teacher',
                                color: category == "teacher"
                                    ? Colors.white
                                    : Colors.black54,
                                value: "teacher",
                                groupValue: category,
                                onChanged: (e) => valueChanged1(e),
                                fontSize:
                                    0.016 * MediaQuery.of(context).size.height,
                              ))
                            ],
                          ),
                        ),

                        SizedBox(
                          height: 15.0,
                        ),
                        //Vaccination status
                        DropdownButtonFormField(
                          iconDisabledColor: Colors.black,
                          iconEnabledColor: Colors.black,
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    style: BorderStyle.solid,
                                    color: Colors.cyan),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    style: BorderStyle.solid,
                                    color: Colors.cyan),
                              ),
                              contentPadding: const EdgeInsets.only(left: 15),
                              focusColor: Color(0XFF011627).withOpacity(0.44),
                              labelText: "Vaccination Status",
                              labelStyle: TextStyle(
                                fontSize:
                                    0.022 * MediaQuery.of(context).size.height,
                                fontWeight: FontWeight.w700,
                                color: Colors.cyan,
                              ),
                              fillColor: Colors.white.withOpacity(0.3),
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.cyan,
                                      style: BorderStyle.solid)),
                              border: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.cyan),
                              )),
                          items: vacStatus
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Text(
                                '$value',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 0.020 *
                                      MediaQuery.of(context).size.height,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              vac = val;
                              print(vac);
                            });
                            setState(() {});
                          },
                        ),
                        SizedBox(
                          height: 15.0,
                        ),

                        //Number of Dose.
                        Visibility(
                          visible: vac == 'Yes',
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                border: Border.all(color: Colors.cyan),
                                borderRadius: BorderRadius.circular(4)),
                            child: Row(
                              children: [
                                Expanded(
                                    child: MyListTile(
                                  title: 'One Dose',
                                  color:
                                      dose == 1 ? Colors.white : Colors.black54,
                                  fontSize: 0.01486 *
                                      MediaQuery.of(context).size.height,
                                  value: 1,
                                  groupValue: dose,
                                  onChanged: (e) => valueChanged(e),
                                )),
                                Expanded(
                                    child: MyListTile(
                                  title: 'Two Dose',
                                  value: 2,
                                  color:
                                      dose == 2 ? Colors.white : Colors.black54,
                                  fontSize: 0.01486 *
                                      MediaQuery.of(context).size.height,
                                  groupValue: dose,
                                  onChanged: (e) => valueChanged(e),
                                ))
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24.0,
                        ),

                        //Create New User on Database.
                        RoundButton(
                            color: Colors.cyan,
                            text: 'Sign Up',
                            onPressed: () async {
                              var val = "c";
                              try {
                                if (widget.useremail != null &&
                                    category != "" &&
                                    password != null &&
                                    name != null &&
                                    vac != null) {
                                  final newUser = await _auth
                                      .createUserWithEmailAndPassword(
                                          email: widget.useremail,
                                          password: password)
                                      .then((newUser) => {
                                            print("yahaaaaaaaaaaaaaaaa"),
                                            _userServices.createUser({
                                              "username": name,
                                              "email": widget.useremail,
                                              "category": category,
                                              "userId": _auth.currentUser.uid,
                                              "vac": vac,
                                              "dose": dose
                                            }),
                                            val = "c",
                                          })
                                      .catchError((err) => {
                                            val = "w",
                                            if (widget.useremail == null)
                                              {
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
                                                            color: Colors.white,
                                                            fontSize: 20),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      width: 120,
                                                    )
                                                  ],
                                                ).show()
                                              }
                                            else
                                              {
                                                Alert(
                                                  context: context,
                                                  type: AlertType.error,
                                                  title: "ALERT",
                                                  desc: "${err.toString()}",
                                                  buttons: [
                                                    DialogButton(
                                                      child: Text(
                                                        "Close",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      width: 120,
                                                    )
                                                  ],
                                                ).show()
                                              }
                                          });

                                  if (newUser != null &&
                                      widget.useremail != null &&
                                      category != "" &&
                                      password != null &&
                                      name != null &&
                                      vac != null &&
                                      val != "w") {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                ClassList()));
                                  }
                                } else {
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
                                                color: Colors.white,
                                                fontSize: 20),
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
                                      desc: "Fill all Fields.",
                                      buttons: [
                                        DialogButton(
                                          child: Text(
                                            "Close",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          width: 120,
                                        )
                                      ],
                                    ).show();
                                  }
                                }
                              } catch (e) {
                                print(e);
                              }
                            }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
