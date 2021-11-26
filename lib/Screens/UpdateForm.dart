//Screen to Update User Details.

import 'package:flutter/material.dart';
import 'package:microsoft_app/widgets/myButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:collection';

class Details extends StatefulWidget {
  @override
  final User user;
  Details({this.user});
  _DetailsState createState() => _DetailsState();
}

final databaseRef = FirebaseDatabase.instance.reference();

class _DetailsState extends State<Details> {
  String userCat, username, myKey, userVac;
  int userShot;

//Function to get data from Realtime Database.
  getRealtimeFirebase() async {
    databaseRef.once().then((DataSnapshot snapshot) {
      var data = snapshot.value["users"];
      data.forEach((key, val) {
        if (val["userId"] == widget.user.uid) {
          setState(() {
            userCat = val["category"];
            username = val["username"];
            userVac = val['vac'];
            userShot = val['dose'];
          });
        }
      });
      setState(() {});
    });
  }

  void getData() async {
    //Retrieve Data
    await getRealtimeFirebase();
  }

  String vac;
  int num = 0;
  final List<String> gs = <String>['Yes', 'No'];
  @override
  Widget build(BuildContext context) {
    //change value of dropdown.
    valueChanged(e) {
      setState(() {
        num = e;
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
                    colors: [Colors.white30, Colors.cyan])),
          ),

          //Dropdown to Select Vaccination Status.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                DropdownButtonFormField(
                  iconDisabledColor: Colors.black,
                  iconEnabledColor: Colors.black,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            style: BorderStyle.solid, color: Colors.cyan),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            style: BorderStyle.solid, color: Colors.cyan),
                      ),
                      contentPadding: const EdgeInsets.only(left: 15),
                      focusColor: Color(0XFF011627).withOpacity(0.44),
                      labelText: "Vaccination Status",
                      labelStyle: TextStyle(
                        fontSize: 0.022 * MediaQuery.of(context).size.height,
                        fontWeight: FontWeight.w700,
                        color: Colors.cyan,
                      ),
                      fillColor: Colors.white.withOpacity(0.3),
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.cyan, style: BorderStyle.solid)),
                      border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.cyan),
                      )),
                  items: gs.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(
                        '$value',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 0.020 * MediaQuery.of(context).size.height,
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
                            child: ListTile(
                          title: Text(
                            'One Dose',
                            style: TextStyle(
                              color: num == 1 ? Colors.black : Colors.black54,
                              fontSize:
                                  0.01486 * MediaQuery.of(context).size.height,
                            ),
                            textAlign: TextAlign.end,
                          ),
                          trailing: Radio(
                            value: 1,
                            groupValue: num,
                            onChanged: (e) => valueChanged(e),
                          ),
                        )),
                        Expanded(
                            child: ListTile(
                          title: Text(
                            'Two Dose',
                            style: TextStyle(
                              color: num == 2 ? Colors.black : Colors.black54,
                              fontSize:
                                  0.01486 * MediaQuery.of(context).size.height,
                            ),
                            textAlign: TextAlign.end,
                          ),
                          trailing: Radio(
                            //   activeColor: Colors.cyan.shade900,
                            value: 2,
                            groupValue: num,
                            onChanged: (e) => valueChanged(e),
                          ),
                        ))
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 24.0,
                ),

                //Update Data of the database.
                RoundButton(
                    color: Colors.cyan[800],
                    text: 'REQUEST',
                    onPressed: () async {
                      databaseRef.once().then((DataSnapshot snapshot) {
                        var data = snapshot.value["users"];
                        data.forEach((key, val) {
                          if (val["userId"] == widget.user.uid) {
                            myKey = key;
                          }
                        });
                        Map<String, Object> createDoc = HashMap();
                        createDoc['vac'] = vac;
                        createDoc['dose'] = num;
                        databaseRef
                            .child('users')
                            .child(myKey)
                            .update(createDoc);
                        Navigator.pop(context);
                      });
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
