//Creating An Event in the calendar.

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Calendar_files/event_info.dart';
import '../../widgets/color.dart';
import '../../Calendar_files/calender_client.dart';
import '../../db/storage.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';

class CreateScreen extends StatefulWidget {
  String username;
  CreateScreen({this.username});
  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  User user;
  List<Object> stud = [];
  int _currentHorizontalIntValue = 5;
  final _auth = FirebaseAuth.instance;

  //Get Current User
  void getCurrentUser() async {
    try {
      user = _auth.currentUser;
      if (user != null) {
        print(user.email);
      }
    } catch (e) {
      print(e);
    }
  }

  Storage storage = Storage();
  CalendarClient calendarClient = CalendarClient();

  TextEditingController textControllerDate;
  TextEditingController textControllerStartTime;
  TextEditingController textControllerEndTime;
  TextEditingController textControllerSubject;
  TextEditingController textControllerAttendee;

  FocusNode textFocusNodeSubject;
  FocusNode textFocusNodeAttendee;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedStartTime = TimeOfDay.now();
  TimeOfDay selectedEndTime = TimeOfDay.now();

  String currentSubject;
  String errorString = '';
  List<calendar.EventAttendee> attendeeEmails = [];

  bool isEditingDate = false;
  bool isEditingStartTime = false;
  bool isEditingEndTime = false;
  bool isEditingBatch = false;
  bool isEditingSubject = false;
  bool isEditingLink = false;
  bool isErrorTime = false;
  bool shouldNotifyAttendees = false;
  bool hasConferenceSupport = false;

  bool isDataStorageInProgress = false;

  //Select start date of Class.
  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        textControllerDate.text = DateFormat.yMMMMd().format(selectedDate);
      });
    }
  }

  //Start Time of Class.
  _selectStartTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedStartTime,
    );
    if (picked != null && picked != selectedStartTime) {
      setState(() {
        selectedStartTime = picked;
        textControllerStartTime.text = selectedStartTime.format(context);
      });
    } else {
      setState(() {
        textControllerStartTime.text = selectedStartTime.format(context);
      });
    }
  }

  //End time of Class.
  _selectEndTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedEndTime,
    );
    if (picked != null && picked != selectedEndTime) {
      setState(() {
        selectedEndTime = picked;
        textControllerEndTime.text = selectedEndTime.format(context);
      });
    } else {
      setState(() {
        textControllerEndTime.text = selectedEndTime.format(context);
      });
    }
  }

  String _validateSubject(String value) {
    if (value != null) {
      value = value?.trim();
      if (value.isEmpty) {
        return 'Subject can\'t be empty';
      }
    } else {
      return 'Subject can\'t be empty';
    }

    return null;
  }

  @override
  void initState() {
    getCurrentUser();
    textControllerDate = TextEditingController();
    textControllerStartTime = TextEditingController();
    textControllerEndTime = TextEditingController();
    textControllerSubject = TextEditingController();
    textControllerAttendee = TextEditingController();

    textFocusNodeSubject = FocusNode();
    textFocusNodeAttendee = FocusNode();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('ViRoom'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.black, Colors.cyan])),
          ),
        ),
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
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You will have access to modify or remove the event afterwards.',
                          style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Teko',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5),
                        ),
                        SizedBox(height: 16.0),
                        RichText(
                          text: TextSpan(
                            text: 'SELECT DATE',
                            style: TextStyle(
                              color: Colors.cyan,
                              fontFamily: 'Amiri',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: '*',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 28,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextField(
                          cursorColor: Colors.cyan,
                          controller: textControllerDate,
                          textCapitalization: TextCapitalization.characters,
                          onTap: () => _selectDate(context),
                          readOnly: true,
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          decoration: new InputDecoration(
                            disabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0)),
                              borderSide:
                                  BorderSide(color: Colors.cyan, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0)),
                              borderSide:
                                  BorderSide(color: Colors.cyan, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0)),
                              borderSide: BorderSide(
                                  color: Colors.cyanAccent, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0)),
                              borderSide:
                                  BorderSide(color: Colors.redAccent, width: 2),
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0)),
                            ),
                            contentPadding: EdgeInsets.only(
                              left: 16,
                              bottom: 16,
                              top: 16,
                              right: 16,
                            ),
                            hintText: 'eg: September 10, 2020',
                            hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.6),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            errorText:
                                isEditingDate && textControllerDate.text != null
                                    ? textControllerDate.text.isNotEmpty
                                        ? null
                                        : 'Date can\'t be empty'
                                    : null,
                            errorStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        RichText(
                          text: TextSpan(
                            text: 'START TIME',
                            style: TextStyle(
                              color: Colors.cyan,
                              fontFamily: 'Amiri',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: '*',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 28,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextField(
                          cursorColor: CustomColor.sea_blue,
                          controller: textControllerStartTime,
                          onTap: () => _selectStartTime(context),
                          readOnly: true,
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          decoration: new InputDecoration(
                            disabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0)),
                              borderSide:
                                  BorderSide(color: Colors.cyan, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0)),
                              borderSide:
                                  BorderSide(color: Colors.cyan, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0)),
                              borderSide: BorderSide(
                                  color: Colors.cyanAccent, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0)),
                              borderSide:
                                  BorderSide(color: Colors.redAccent, width: 2),
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0)),
                            ),
                            contentPadding: EdgeInsets.only(
                              left: 16,
                              bottom: 16,
                              top: 16,
                              right: 16,
                            ),
                            hintText: 'eg: 09:30 AM',
                            hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.6),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            errorText: isEditingStartTime &&
                                    textControllerStartTime.text != null
                                ? textControllerStartTime.text.isNotEmpty
                                    ? null
                                    : 'Start time can\'t be empty'
                                : null,
                            errorStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        RichText(
                          text: TextSpan(
                            text: 'END TIME',
                            style: TextStyle(
                              color: Colors.cyan,
                              fontFamily: 'Amiri',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: '*',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 28,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextField(
                          cursorColor: CustomColor.sea_blue,
                          controller: textControllerEndTime,
                          onTap: () => _selectEndTime(context),
                          readOnly: true,
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          decoration: new InputDecoration(
                            disabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0)),
                              borderSide:
                                  BorderSide(color: Colors.cyan, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0)),
                              borderSide:
                                  BorderSide(color: Colors.cyan, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0)),
                              borderSide: BorderSide(
                                  color: Colors.cyanAccent, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0)),
                              borderSide:
                                  BorderSide(color: Colors.redAccent, width: 2),
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0)),
                            ),
                            contentPadding: EdgeInsets.only(
                              left: 16,
                              bottom: 16,
                              top: 16,
                              right: 16,
                            ),
                            hintText: 'eg: 11:30 AM',
                            hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.6),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            errorText: isEditingEndTime &&
                                    textControllerEndTime.text != null
                                ? textControllerEndTime.text.isNotEmpty
                                    ? null
                                    : 'End time can\'t be empty'
                                : null,
                            errorStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        RichText(
                          text: TextSpan(
                            text: 'SUBJECT',
                            style: TextStyle(
                              color: Colors.cyan,
                              fontFamily: 'Amiri',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: '*',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 28,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextField(
                          enabled: true,
                          cursorColor: CustomColor.sea_blue,
                          focusNode: textFocusNodeSubject,
                          controller: textControllerSubject,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {
                            setState(() {
                              isEditingSubject = true;
                              currentSubject = value;
                            });
                          },
                          onSubmitted: (value) {
                            textFocusNodeSubject.unfocus();
                            FocusScope.of(context)
                                .requestFocus(textFocusNodeAttendee);
                          },
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          decoration: new InputDecoration(
                            disabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0)),
                              borderSide:
                                  BorderSide(color: Colors.cyan, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0)),
                              borderSide:
                                  BorderSide(color: Colors.cyan, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0)),
                              borderSide: BorderSide(
                                  color: Colors.cyanAccent, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0)),
                              borderSide:
                                  BorderSide(color: Colors.redAccent, width: 2),
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0)),
                            ),
                            contentPadding: EdgeInsets.only(
                              left: 16,
                              bottom: 16,
                              top: 16,
                              right: 16,
                            ),
                            hintText: 'eg: Maths',
                            hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.6),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            errorText: isEditingSubject
                                ? _validateSubject(currentSubject)
                                : null,
                            errorStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        //Maximum Students
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            NumberPicker(
                              value: _currentHorizontalIntValue,
                              minValue: 0,
                              maxValue: 100,
                              step: 1,
                              itemHeight: 50,
                              axis: Axis.horizontal,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              textStyle: TextStyle(color: Colors.black),
                              selectedTextStyle: TextStyle(
                                color: Colors.cyanAccent,
                              ),
                              onChanged: (value) => setState(
                                  () => _currentHorizontalIntValue = value),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () => setState(() {
                                final newValue =
                                    _currentHorizontalIntValue - 10;
                                _currentHorizontalIntValue =
                                    newValue.clamp(0, 100);
                              }),
                            ),
                            Text(
                              'Max Students: $_currentHorizontalIntValue',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Amiri",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () => setState(() {
                                final newValue =
                                    _currentHorizontalIntValue + 20;
                                _currentHorizontalIntValue =
                                    newValue.clamp(0, 100);
                              }),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),

                        Visibility(
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Notify attendees',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Raleway',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Switch(
                                    value: shouldNotifyAttendees,
                                    onChanged: (value) {
                                      setState(() {
                                        shouldNotifyAttendees = value;
                                      });
                                    },
                                    activeColor: Colors.cyanAccent,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add video conferencing',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Raleway',
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Switch(
                              value: hasConferenceSupport,
                              onChanged: (value) {
                                setState(() {
                                  hasConferenceSupport = value;
                                });
                              },
                              activeColor: Colors.cyanAccent,
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        Container(
                          width: double.maxFinite,
                          child: RaisedButton(
                            elevation: 0,
                            focusElevation: 0,
                            highlightElevation: 0,
                            color: Colors.cyan,
                            onPressed: isDataStorageInProgress
                                ? null
                                : () async {
                                    print("hbgvfcdxs");
                                    setState(() {
                                      isErrorTime = false;
                                      isDataStorageInProgress = true;
                                    });

                                    textFocusNodeSubject.unfocus();
                                    textFocusNodeAttendee.unfocus();

                                    if (selectedDate != null &&
                                        selectedStartTime != null &&
                                        selectedEndTime != null &&
                                        currentSubject != null) {
                                      int startTimeInEpoch = DateTime(
                                        selectedDate.year,
                                        selectedDate.month,
                                        selectedDate.day,
                                        selectedStartTime.hour,
                                        selectedStartTime.minute,
                                      ).millisecondsSinceEpoch;

                                      int endTimeInEpoch = DateTime(
                                        selectedDate.year,
                                        selectedDate.month,
                                        selectedDate.day,
                                        selectedEndTime.hour,
                                        selectedEndTime.minute,
                                      ).millisecondsSinceEpoch;

                                      print(
                                          'DIFFERENCE: ${endTimeInEpoch - startTimeInEpoch}');

                                      print(
                                          'Start Time: ${DateTime.fromMillisecondsSinceEpoch(startTimeInEpoch)}');
                                      print(
                                          'End Time: ${DateTime.fromMillisecondsSinceEpoch(endTimeInEpoch)}');

                                      if (endTimeInEpoch - startTimeInEpoch >
                                          0) {
                                        if (_validateSubject(currentSubject) ==
                                            null) {
                                          await calendarClient
                                              .insert(
                                                  maxStud:
                                                      _currentHorizontalIntValue,
                                                  useremail: user.email,
                                                  userid: user.uid,
                                                  username: widget.username,
                                                  subject: currentSubject,
                                                  attendeeEmailList:
                                                      attendeeEmails,
                                                  shouldNotifyAttendees:
                                                      shouldNotifyAttendees,
                                                  hasConferenceSupport:
                                                      hasConferenceSupport,
                                                  startTime: DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          startTimeInEpoch),
                                                  endTime: DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          endTimeInEpoch))
                                              .then((eventData) async {
                                            String eventId = eventData['id'];
                                            String eventLink =
                                                eventData['link'];

                                            List<String> emails = [];

                                            for (int i = 0;
                                                i < attendeeEmails.length;
                                                i++)
                                              emails
                                                  .add(attendeeEmails[i].email);

                                            print(emails);
                                            List<Object> stud = [];
                                            EventInfo eventInfo = EventInfo(
                                                maxStud:
                                                    _currentHorizontalIntValue,
                                                id: eventId,
                                                subject: currentSubject,
                                                username: widget.username,
                                                useremail: user.email,
                                                userid: user.uid,
                                                link: eventLink,
                                                attendeeEmails: emails,
                                                shouldNotifyAttendees:
                                                    shouldNotifyAttendees,
                                                hasConfereningSupport:
                                                    hasConferenceSupport,
                                                startTimeInEpoch:
                                                    startTimeInEpoch,
                                                endTimeInEpoch: endTimeInEpoch,
                                                stud: stud);

                                            await storage
                                                .storeEventData(eventInfo)
                                                .whenComplete(() =>
                                                    Navigator.of(context).pop())
                                                .catchError(
                                                  (e) => print(e),
                                                );
                                          }).catchError(
                                            (e) => print(e),
                                          );

                                          setState(() {
                                            isDataStorageInProgress = false;
                                          });
                                        } else {
                                          setState(() {
                                            isEditingSubject = true;
                                            isEditingLink = true;
                                          });
                                        }
                                      } else {
                                        setState(() {
                                          isErrorTime = true;
                                          errorString =
                                              'Invalid time! Please use a proper start and end time';
                                        });
                                      }
                                    } else {
                                      setState(() {
                                        isEditingDate = true;
                                        isEditingStartTime = true;
                                        isEditingEndTime = true;
                                        isEditingBatch = true;
                                        isEditingSubject = true;
                                        isEditingLink = true;
                                      });
                                    }
                                    setState(() {
                                      isDataStorageInProgress = false;
                                    });
                                  },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                              child: isDataStorageInProgress
                                  ? SizedBox(
                                      height: 28,
                                      width: 28,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'ADD',
                                      style: TextStyle(
                                        fontFamily: 'Raleway',
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: isErrorTime,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                errorString,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
