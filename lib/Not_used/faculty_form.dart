// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:microsoft_app/widgets/myButton.dart';
// import 'package:microsoft_app/constant.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:numberpicker/numberpicker.dart';
// import 'package:rflutter_alert/rflutter_alert.dart';
//
// final _fireStore = FirebaseFirestore.instance;
//
// class FacForm extends StatefulWidget {
//   String username;
//   FacForm({this.username});
//   @override
//   _FacFormState createState() => _FacFormState();
// }
//
// class _FacFormState extends State<FacForm> {
//   User user;
//   String finalDate, time, fromDate, name, subject;
//   DateTime sortdate;
//   TimeOfDay sortTime;
//   List<Object> stud = [];
//   int _currentHorizontalIntValue = 0;
//   final _auth = FirebaseAuth.instance;
//
//   @override
//   void initState() {
//     super.initState();
//     getCurrentUser();
//   }
//
//   //Get Current User
//   void getCurrentUser() async {
//     try {
//       user = _auth.currentUser;
//       if (user != null) {
//         print(user.email);
//       }
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Stack(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [Colors.white30, Colors.cyan])),
//             ),
//             Center(
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 24.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: <Widget>[
//                       SizedBox(
//                         height: 20.0,
//                       ),
//                       //Subject TextField
//                       TextField(
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontWeight: FontWeight.w500,
//                           fontSize: 0.020 * MediaQuery.of(context).size.height,
//                         ),
//                         onChanged: (value) {
//                           subject = value;
//                         },
//                         decoration: kInputField.copyWith(
//                           filled: true,
//                           fillColor: Colors.white.withOpacity(0.3),
//                           hintText: 'Subject',
//                           hintStyle: TextStyle(color: Colors.black54),
//                           labelText: 'Subject',
//                           labelStyle: TextStyle(
//                             fontSize:
//                                 0.022 * MediaQuery.of(context).size.height,
//                             fontWeight: FontWeight.w700,
//                             color: Colors.cyan,
//                           ),
//                           floatingLabelBehavior: FloatingLabelBehavior.always,
//                         ),
//                       ),
//
//                       SizedBox(
//                         height: 15.0,
//                       ),
//
//                       //Date Picker
//                       Container(
//                         margin: EdgeInsets.symmetric(
//                             horizontal:
//                                 0.09 * MediaQuery.of(context).size.height),
//                         child: RawMaterialButton(
//                             fillColor: Colors.cyan[100],
//                             elevation: 10.0,
//                             onPressed: () {
//                               showDatePicker(
//                                 context: context,
//                                 initialDate: DateTime.now(),
//                                 firstDate: DateTime.now(),
//                                 lastDate: DateTime(2110),
//                               ).then((date) {
//                                 sortdate = date;
//                                 setState(() {
//                                   finalDate = date.year.toString() +
//                                       "-" +
//                                       date.month.toString() +
//                                       "-" +
//                                       date.day.toString();
//                                   fromDate = finalDate;
//                                 });
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 fromDate == null
//                                     ? Text(
//                                         "Choose Date: ",
//                                         style: TextStyle(
//                                           color: Colors.black,
//                                           fontFamily: "Amiri",
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       )
//                                     : Text(
//                                         "$fromDate",
//                                         style: TextStyle(
//                                           color: Colors.black,
//                                           fontWeight: FontWeight.bold,
//                                           fontFamily: "Amiri",
//                                         ),
//                                       ),
//                                 Icon(Icons.calendar_today),
//                               ],
//                             )),
//                       ),
//
//                       SizedBox(
//                         height: 15.0,
//                       ),
//
//                       //Time Picker
//                       Container(
//                         margin: EdgeInsets.symmetric(
//                             horizontal:
//                                 0.09 * MediaQuery.of(context).size.height),
//                         child: RawMaterialButton(
//                             fillColor: Colors.cyan[100],
//                             elevation: 10.0,
//                             onPressed: () {
//                               print("from");
//                               showTimePicker(
//                                       context: context,
//                                       initialTime: TimeOfDay.now(),
//                                       confirmText: "Add")
//                                   .then((value2) {
//                                 sortTime = value2;
//                                 int d = value2.hour;
//                                 int e = value2.minute;
//                                 setState(() {
//                                   print(d);
//                                   if (d == 0) {
//                                     time = "${d + 12} : $e am";
//                                   } else if (d == 12) {
//                                     time = "$d : $e pm";
//                                   } else if (d > 12) {
//                                     time = "${d - 12} : $e pm";
//                                   } else {
//                                     time = " $d : $e am";
//                                   }
//                                 });
//
//                                 //showTimePicker(context: context, initialTime: TimeOfDay.now()).then((value) {
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 time == null
//                                     ? Text(
//                                         "Choose Time: ",
//                                         style: TextStyle(
//                                           color: Colors.black,
//                                           fontFamily: "Amiri",
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       )
//                                     : Text(
//                                         "$time",
//                                         style: TextStyle(
//                                           color: Colors.black,
//                                           fontWeight: FontWeight.bold,
//                                           fontFamily: "Amiri",
//                                         ),
//                                       ),
//                                 Icon(Icons.watch),
//                               ],
//                             )),
//                       ),
//
//                       SizedBox(
//                         height: 15,
//                       ),
//
//                       //Maximum Students
//                       NumberPicker(
//                         value: _currentHorizontalIntValue,
//                         minValue: 0,
//                         maxValue: 100,
//                         step: 1,
//                         itemHeight: 50,
//                         axis: Axis.horizontal,
//                         onChanged: (value) =>
//                             setState(() => _currentHorizontalIntValue = value),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(color: Colors.black26, width: 2),
//                         ),
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           IconButton(
//                             icon: Icon(Icons.remove),
//                             onPressed: () => setState(() {
//                               final newValue = _currentHorizontalIntValue - 10;
//                               _currentHorizontalIntValue =
//                                   newValue.clamp(0, 100);
//                             }),
//                           ),
//                           Text(
//                             'Max Students: $_currentHorizontalIntValue',
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontFamily: "Amiri",
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.add),
//                             onPressed: () => setState(() {
//                               final newValue = _currentHorizontalIntValue + 20;
//                               _currentHorizontalIntValue =
//                                   newValue.clamp(0, 100);
//                             }),
//                           ),
//                         ],
//                       ),
//
//                       SizedBox(
//                         height: 24.0,
//                       ),
//
//                       //Adding Class to the List.
//                       RoundButton(
//                           color: Colors.cyan[800],
//                           text: 'ADD',
//                           onPressed: () async {
//                             if (subject != null &&
//                                 time != null &&
//                                 fromDate != null &&
//                                 _currentHorizontalIntValue != 0) {
//                               await _fireStore.collection("class").add({
//                                 'sortdate': DateTime(
//                                     sortdate.year,
//                                     sortdate.month,
//                                     sortdate.day,
//                                     sortTime.hour,
//                                     sortTime.minute),
//                                 'uid': user.uid,
//                                 'mail': user.email,
//                                 'name': widget.username,
//                                 'subject': subject,
//                                 'time': time,
//                                 'date': fromDate,
//                                 'maxStud': _currentHorizontalIntValue,
//                                 'students': stud,
//                               });
//                               await _fireStore
//                                   .collection('${user.uid}')
//                                   .doc(user.uid)
//                                   .collection('class')
//                                   .add({
//                                 'uid': user.uid,
//                                 'mail': user.email,
//                                 'name': widget.username,
//                                 'subject': subject,
//                                 'time': time,
//                                 'date': fromDate,
//                                 'maxStud': _currentHorizontalIntValue,
//                                 'students': stud,
//                               });
//                               Navigator.pop(context);
//                             } else {
//                               Alert(
//                                 context: context,
//                                 type: AlertType.error,
//                                 title: "ALERT",
//                                 desc: "Fill all Fields.",
//                                 buttons: [
//                                   DialogButton(
//                                     child: Text(
//                                       "Close",
//                                       style: TextStyle(
//                                           color: Colors.white, fontSize: 20),
//                                     ),
//                                     onPressed: () {
//                                       Navigator.pop(context);
//                                     },
//                                     width: 120,
//                                   )
//                                 ],
//                               ).show();
//                             }
//                           }),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
