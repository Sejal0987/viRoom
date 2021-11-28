//Scheduler Screen.
import 'package:googleapis/calendar/v3.dart' as calendar;
import '../../Calendar_files/calender_client.dart';
import '../../db/storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import 'package:firebase_database/firebase_database.dart';
import '../UpdateForm.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:microsoft_app/widgets/drawer_inkWell.dart';
import '../Event_creation/create_screen.dart';
import '../../Calendar_files/event_info.dart';

class ClassList extends StatefulWidget {
  @override
  _ClassListState createState() => _ClassListState();
}

final databaseRef = FirebaseDatabase.instance.reference();
final _fireStore = FirebaseFirestore.instance;

class _ClassListState extends State<ClassList> {
  String userCat, username, userVac;
  int userDose;

  getRealtimeFirebase() async {
    //Function to get data from Realtime Database.
    databaseRef.once().then((DataSnapshot snapshot) {
      var data = snapshot.value["users"];
      data.forEach((key, val) {
        if (val["userId"] == user.uid) {
          setState(() {
            userCat = val["category"];
            username = val["username"];
            userVac = val['vac'];
            userDose = val['dose'];
          });
        }
      });
      setState(() {});
    });
  }

  User user;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    setState(() {
      getData();
    });
  }

  void changeState() {
    setState(() {});
  }

  void getData() async {
    await getRealtimeFirebase();
  }

  //Get Current user.
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
          child: Scaffold(
        //button to add class only visible when user is a faculty.
        floatingActionButton: Visibility(
          visible: userCat == "teacher",
          child: FloatingActionButton(
            backgroundColor: Colors.cyan[600],
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => CreateScreen(
                            username: username,
                          )));
            },
          ),
        ),
        //Drawer containing user's details.
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text('$username'),
                currentAccountPicture: GestureDetector(
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[Colors.black, Colors.cyan])),
              ),
              DrawerInkWell(
                onTap: () {},
                title: '$userCat',
                sub: '',
                icons: Icon(Icons.school_rounded, color: Colors.cyan),
              ),
              DrawerInkWell(
                onTap: () {},
                title: 'Name',
                sub: '$username',
                icons: Icon(Icons.person_search, color: Colors.cyan),
              ),
              DrawerInkWell(
                onTap: () {},
                title: 'Email',
                sub: '${user.email}',
                icons: Icon(Icons.email_rounded, color: Colors.cyan),
              ),
              DrawerInkWell(
                onTap: () {},
                title: 'Vacination Status',
                sub: '$userVac',
                icons: Icon(Icons.medical_services, color: Colors.cyan),
              ),
              Visibility(
                visible: userVac == 'Yes',
                child: DrawerInkWell(
                  onTap: () {},
                  title: 'No. of Dose',
                  sub: '$userDose',
                  icons: Icon(Icons.medical_services, color: Colors.cyan),
                ),
              ),
              Divider(),

              //Button to update user deatails.
              GestureDetector(
                onTap: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  Details(user: user)))
                      .whenComplete(() => {getData()});
                },
                child: DrawerInkWell(
                  sub: '',
                  title: 'Update Details',
                  icons: Icon(
                    Icons.update,
                    color: Colors.cyan,
                  ),
                ),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          centerTitle: true,
          title: Text('ViRoom'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Colors.black, Colors.cyan])),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context); // do something
              },
            )
          ],
        ),
        body: RefreshIndicator(
            color: Colors.black,
            onRefresh: () async {
              setState(() {});
              await _refresh_work_history();
            },
            child: MyBody(
              userid: user.uid,
              category: userCat,
              uemail: user.email,
              username: username,
              userDose: userDose,
              userVac: userVac,
            )),
      )),
    );
  }
}

class MyBody extends StatelessWidget {
  final userid, category, uemail, username, userVac;
  int userDose;
  bool clickable = true;
  String status;
  MyBody(
      {this.userid,
      this.category,
      this.uemail,
      this.username,
      this.userVac,
      this.userDose});

  //Function to check whether class is requested or not.
  Future func(List<Object> lst) async {
    clickable = true;
    status = "";
    if (lst.length > 0) {
      for (var i in lst) {
        var lt = i as Map;
        if (lt['email'] == uemail) {
          clickable = false;
          status = lt['status'];
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    clickable = true;

    //StreamBuilder used to get snapshot of data from Database collection.
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore.collection('class').orderBy('start').snapshots(),
      builder: (context, snapshot) {
        List<MyContainer> myContainer = [];

        //Loading Data
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.blueAccent,
            ),
          );
        }

        //Getting data from cloud firestore
        final message = snapshot.data.docs;
        print(message);
        for (var msg in message) {
          print(msg['username']);
          Map<String, dynamic> eventInfo = msg.data();

          EventInfo event = EventInfo.fromMap(eventInfo);
          DateTime startTime =
              DateTime.fromMillisecondsSinceEpoch(msg['start']);
          DateTime endTime = DateTime.fromMillisecondsSinceEpoch(msg['end']);

          String startTimeString = DateFormat.jm().format(startTime);
          String endTimeString = DateFormat.jm().format(endTime);
          String dateString = DateFormat.yMMMMd().format(startTime);

          final String name = msg['username'],
              subject = msg['subject'],
              time = '$startTimeString - $endTimeString',
              date = '$dateString',
              uid = msg['uid'];
          func(msg['students']);
          bool tf;
          if (userid == uid) {
            tf = true;
          } else {
            tf = false;
          }
          print("jhgfds");

          //Adding class container.
          myContainer.add(MyContainer(
              time: time,
              date: date,
              name: name,
              uid: uid,
              tf: tf,
              clickable: clickable,
              status: status,
              documents: msg,
              uemail: uemail,
              subject: subject,
              category: category,
              username: username,
              userId: userid,
              userVac: userVac,
              userDose: userDose,
              event: event,
              index: myContainer.length));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListView(
            children: myContainer,
          ),
        );
      },
    );
  }
}

class MyContainer extends StatefulWidget {
  final EventInfo event;
  final String name,
      subject,
      time,
      date,
      uid,
      category,
      uemail,
      status,
      username,
      userId,
      userVac;
  int userDose, index;
  final bool tf, clickable;
  final DocumentSnapshot documents;
  MyContainer(
      {this.time,
      this.event,
      this.name,
      this.subject,
      this.date,
      this.documents,
      this.uid,
      this.uemail,
      this.tf,
      this.clickable,
      this.status,
      this.category,
      this.username,
      this.userId,
      this.userVac,
      this.userDose,
      this.index});

  @override
  _MyContainerState createState() => _MyContainerState();
}

class _MyContainerState extends State<MyContainer> {
  Storage storage = Storage();
  CalendarClient calendarClient = CalendarClient();
  @override
  Widget build(BuildContext buildContext) {
    Color color = Colors.black26;

    //Dialog Box of List of Students Requested.
    Future<void> _displayTextInputDialog(BuildContext context, List<Object> lst,
        final DocumentSnapshot documents) async {
      return showDialog(
          context: context,
          builder: (context) {
            if (lst.length == 0) {
              // If Count of Students requested is 0.
              return Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoSizeText(
                        "No Student Requested.",
                        maxLines: 2,
                        minFontSize: 10,
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.redAccent,
                            fontFamily: "Teko",
                            fontSize: 30),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      RawMaterialButton(
                        fillColor: Colors.cyan,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 8),
                          child: Text(
                            "BACK",
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                fontFamily: "Teko",
                                fontSize: 20),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            } else {
              //Details of Requested Students.
              return ListView.builder(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  itemCount: lst.length,
                  itemBuilder: (context, int i) {
                    List<Object> lst = List.from(documents['students']);
                    var lt = lst[i] as Map;
                    var name = lt['name'];
                    var email = lt['email'];
                    var uid = lt['uid'];
                    var status;
                    if (status == null) {
                      status = lt['status'].toString().toUpperCase();
                    }
                    Color boxcolor = Colors.cyan;
                    if (lt['status'] == 'waiting') {
                      boxcolor = Colors.cyan;
                    } else if (lt['status'] == 'allowed') {
                      boxcolor = Colors.green;
                    } else if (lt['status'] == 'rejected') {
                      boxcolor = Colors.red;
                    }

                    return Container(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          border: Border.all(width: 8, color: Colors.black),
                          color: Colors.grey[400],
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[Colors.white, boxcolor])),
                      height: 200,
                      child: Container(
                        color: Colors.white.withOpacity(0.4),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: AutoSizeText(
                                      '👨🏻‍🎓 ${name.toString().toUpperCase()}',
                                      minFontSize: 10,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 0.026 *
                                              MediaQuery.of(context)
                                                  .size
                                                  .height,
                                          letterSpacing: 1.2,
                                          fontFamily: 'Teko',
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  AutoSizeText(
                                    '⏳ ${status}',
                                    textAlign: TextAlign.end,
                                    minFontSize: 6,
                                    style: TextStyle(
                                        fontSize: 0.016 *
                                            MediaQuery.of(context).size.height,
                                        color: Colors.black.withOpacity(0.5),
                                        letterSpacing: 1.2,
                                        fontFamily: 'Teko',
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              AutoSizeText(
                                '📧 ${email}',
                                textAlign: TextAlign.start,
                                minFontSize: 6,
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 0.016 *
                                        MediaQuery.of(context).size.height,
                                    letterSpacing: 1.2,
                                    fontFamily: 'Teko',
                                    fontWeight: FontWeight.w700),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 2)),
                                          child: AutoSizeText(
                                            '  Vaccination Status : ${lt['vac']}  ',
                                            minFontSize: 10,
                                            style: TextStyle(
                                                fontSize: 0.020 *
                                                    MediaQuery.of(context)
                                                        .size
                                                        .height,
                                                letterSpacing: 1.2,
                                                fontFamily: 'Teko',
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Visibility(
                                          visible: lt['vac'] == 'Yes',
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black,
                                                    width: 2)),
                                            child: AutoSizeText(
                                              '  No. of Dose: ${lt['dose']}  ',
                                              minFontSize: 10,
                                              style: TextStyle(
                                                  fontSize: 0.020 *
                                                      MediaQuery.of(context)
                                                          .size
                                                          .height,
                                                  letterSpacing: 1.2,
                                                  fontFamily: 'Teko',
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  //Buttons to Allow or Reject the students.
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.all(5),
                                        child: RawMaterialButton(
                                          elevation: 2,
                                          fillColor:
                                              lt['status'] == 'allowed' ||
                                                      documents['maxStud'] == 0
                                                  ? Colors.black54
                                                  : Colors.green,
                                          onPressed: () async {
                                            if (lt['status'] != 'allowed' &&
                                                documents['maxStud'] != 0) {
                                              List<Object> lst = List.from(
                                                  documents['students']);
                                              Map lt = lst[i];
                                              print(lt);
                                              lt['status'] = 'allowed';
                                              lst[i] = lt;
                                              print(lst);
                                              await documents.reference.update(
                                                {
                                                  'students': lst,
                                                  'maxStud':
                                                      documents['maxStud'] - 1,
                                                },
                                              ).whenComplete(() =>
                                                  Navigator.pop(context, () {
                                                    setState(() {});
                                                  }));
                                            }
                                          },
                                          child: Text(
                                            'ALLOW',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontFamily: "Teko",
                                                color: lt['status'] ==
                                                            'allowed' ||
                                                        documents['maxStud'] ==
                                                            0
                                                    ? Colors.black
                                                    : Colors.white,
                                                letterSpacing: 1.2),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.all(5),
                                        child: RawMaterialButton(
                                          fillColor:
                                              lt['status'] == 'allowed' ||
                                                      documents['maxStud'] == 0
                                                  ? Colors.black54
                                                  : Colors.red,
                                          onPressed: () async {
                                            print(status);
                                            if (lt['status'] != 'allowed' &&
                                                documents['maxStud'] != 0) {
                                              List<Object> lst = List.from(
                                                  documents['students']);
                                              Map lt = lst[i];
                                              print(lt);
                                              lt['status'] = 'rejected';
                                              lst[i] = lt;
                                              print(lst);
                                              await documents.reference.update(
                                                {
                                                  'students': lst,
                                                },
                                              ).whenComplete(() =>
                                                  Navigator.pop(context, () {
                                                    setState(() {});
                                                  }));
                                            }
                                          },
                                          child: Text(
                                            'REJECT',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontFamily: "Teko",
                                                color: lt['status'] ==
                                                            'allowed' ||
                                                        documents['maxStud'] ==
                                                            0
                                                    ? Colors.black
                                                    : Colors.white,
                                                letterSpacing: 1.2),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            }
          });
    }

    //Color code depending upon status.
    if (widget.status == 'waiting') {
      color = Colors.cyan;
    } else if (widget.status == 'allowed') {
      color = Colors.green;
    } else if (widget.status == 'rejected') {
      color = Colors.red;
    } else {
      color = Colors.black54;
    }
    return Slidable(
      secondaryActions: [
        //Button to get student list.
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RawMaterialButton(
            onPressed: () {
              List<Object> lst = List.from(widget.documents['students']);
              if (widget.documents['maxStud'] == 0) {
                //if students allowed have reached limit.
                Alert(
                  context: buildContext,
                  type: AlertType.info,
                  title: "ALERT",
                  desc: "Maximum students are already Allowed.",
                  buttons: [
                    DialogButton(
                      child: Text(
                        "Close",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.pop(buildContext);
                      },
                      width: 120,
                    )
                  ],
                ).show().whenComplete(() => _displayTextInputDialog(
                    buildContext, lst, widget.documents));
              } else {
                _displayTextInputDialog(buildContext, lst, widget.documents);
              }
            },
            child: Container(
                height: 70,
                decoration: BoxDecoration(
                    color: Colors.cyan.shade100,
                    border: Border.all(color: Colors.cyan.shade900, width: 6)),
                child: Center(
                    child: Text(
                  '👨‍🎓 Students'.toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontFamily: "Amiri"),
                  textAlign: TextAlign.center,
                ))),
          ),
        ),
        Builder(builder: (context) {
          //Button to Delete Class.
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: RawMaterialButton(
              onPressed: () async {
                setState(() {
                  Slidable.of(context).close();
                });
                String eventId = widget.event.id;
                await calendarClient
                    .delete(eventId, true)
                    .whenComplete(() async {
                  await storage
                      .deleteEvent(id: eventId)
                      .catchError((e) => print(e));
                });
                await widget.documents.reference.delete();
              },
              child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                      color: Colors.cyan.shade100,
                      border:
                          Border.all(color: Colors.cyan.shade900, width: 6)),
                  child: Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete),
                      Text(
                        'Delete'.toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontFamily: "Amiri"),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ))),
            ),
          );
        })
      ],

      // Slidable only when logged in by faculty.
      actionExtentRatio: widget.category == "student" || !widget.tf ? 0 : 1 / 2,
      actionPane: SlidableDrawerActionPane(),
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 24),
            height: widget.category == "student" ? 170 : 140,
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: color,
                    blurRadius: 6.0, // soften the shadow
                    spreadRadius: 2.0, //extend the shadow
                    offset: Offset(
                      0.0, // Move to right 10  horizontally
                      5.0, // Move to bottom 10 Vertically
                    ),
                  )
                ],
                color: Colors.grey[400],
                image: DecorationImage(
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Colors.white.withOpacity(0.2), BlendMode.dstATop),
                    image: AssetImage(
                      'images/img.jpg',
                    )),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: Colors.black, width: 2)),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 44, horizontal: 10),
                    child: Visibility(
                      visible: widget.category == "teacher" && widget.tf,
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: color,
                              blurRadius: 6.0, // soften the shadow
                              spreadRadius: 2.0, //extend the shadow
                              offset: Offset(
                                0.0, // Move to right 10  horizontally
                                5.0, // Move to bottom 10 Vertically
                              ),
                            )
                          ],
                        ),

                        //Button which onclick sent the meeting link to all requested students.
                        child: RawMaterialButton(
                          elevation: 3,
                          child: Text(
                            'Send link to all Requested Student.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Teko',
                                fontSize: 14),
                          ),
                          fillColor: Colors.black,
                          onPressed: () async {
                            List<Object> lst =
                                List.from(widget.documents['students']);
                            if (lst.length != 0) {
                              calendar.EventAttendee eventAttendee;
                              List<calendar.EventAttendee> attendeeEmails = [];
                              for (var i = 0; i < lst.length; i++) {
                                var lt = lst[i] as Map;
                                eventAttendee = calendar.EventAttendee();
                                eventAttendee.email = lt['email'];

                                attendeeEmails.add(eventAttendee);
                              }
                              print(attendeeEmails);

                              String eventId = widget.event.id;
                              String currentTitle = widget.documents['subject'];
                              bool shouldNofityAttendees =
                                  widget.documents['should_notify'];
                              bool hasConferenceSupport =
                                  widget.documents['has_conferencing'];
                              String username = widget.documents['username'];
                              String userid = widget.documents['uid'];
                              int maxStud = widget.documents['maxStud'];
                              List<Object> stud = widget.documents['students'];

                              await calendarClient
                                  .modify(
                                      id: eventId,
                                      title: currentTitle,
                                      attendeeEmailList: attendeeEmails,
                                      shouldNotifyAttendees:
                                          shouldNofityAttendees,
                                      hasConferenceSupport:
                                          hasConferenceSupport,
                                      startTime:
                                          DateTime.fromMillisecondsSinceEpoch(
                                              widget.documents['start']),
                                      endTime:
                                          DateTime.fromMillisecondsSinceEpoch(
                                              widget.documents['end']))
                                  .then((value) {
                                Alert(
                                  context: buildContext,
                                  type: AlertType.success,
                                  title: "ALERT",
                                  desc:
                                      "Event added to all the requested students calender.",
                                  buttons: [
                                    DialogButton(
                                      child: Text(
                                        "Close",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(buildContext);
                                      },
                                      width: 120,
                                    )
                                  ],
                                ).show();
                              });
                            } else {
                              Alert(
                                context: buildContext,
                                type: AlertType.warning,
                                title: "ALERT",
                                desc: "No Student requested.",
                                buttons: [
                                  DialogButton(
                                    child: Text(
                                      "Close",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(buildContext);
                                    },
                                    width: 120,
                                  )
                                ],
                              ).show();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Container(
                            color: Colors.white.withOpacity(0.4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                //Subject
                                Container(
                                  width: 0.5 *
                                      MediaQuery.of(buildContext).size.width,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: AutoSizeText(
                                          'SUBJECT : ',
                                          textAlign: TextAlign.end,
                                          minFontSize: 4,
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 0.026 *
                                                  MediaQuery.of(buildContext)
                                                      .size
                                                      .height,
                                              letterSpacing: 1.2,
                                              fontFamily: 'Teko',
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      Expanded(
                                        child: AutoSizeText(
                                          ' ${widget.subject.toUpperCase()}',
                                          textAlign: TextAlign.start,
                                          minFontSize: 4,
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 0.026 *
                                                  MediaQuery.of(buildContext)
                                                      .size
                                                      .height,
                                              letterSpacing: 1.2,
                                              fontFamily: 'Teko',
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                //Faculty Name
                                AutoSizeText(
                                  '👨‍🏫 ${widget.name.toUpperCase()}',
                                  minFontSize: 5.0,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontWeight: FontWeight.w900,
                                    color: Colors.cyan.shade900,
                                    fontSize: 0.021 *
                                        MediaQuery.of(buildContext).size.height,
                                  ),
                                ),

                                //Date & Time.
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: 3),
                                          color: Colors.white.withOpacity(0.2)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              Text('${widget.date}',
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 0.014 *
                                                        MediaQuery.of(
                                                                buildContext)
                                                            .size
                                                            .height,
                                                    color: Colors.black,
                                                    letterSpacing: 1.2,
                                                    fontFamily: "Teko",
                                                  )),
                                              Text('${widget.time}',
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 0.014 *
                                                        MediaQuery.of(
                                                                buildContext)
                                                            .size
                                                            .height,
                                                    color: Colors.black,
                                                    letterSpacing: 1.2,
                                                    fontFamily: "Teko",
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 0.0053 *
                                      MediaQuery.of(buildContext).size.height,
                                ),

                                //Button to request for Joining the class, only visible to students.
                                Visibility(
                                  visible: widget.category == "student",
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (widget.clickable == true &&
                                          widget.documents['maxStud'] != 0) {
                                        List<Object> lst = List.from(
                                            widget.documents['students']);
                                        var lt = lst.length + 1;
                                        lst.add({
                                          'name': '${widget.username}',
                                          'email': widget.uemail,
                                          'uid': widget.userId,
                                          'status': 'waiting',
                                          'vac': widget.userVac,
                                          'dose': widget.userDose,
                                          'count': lt,
                                        });

                                        await widget.documents.reference.update(
                                          {
                                            'students': lst,
                                          },
                                        ).whenComplete(() => setState(() {}));
                                      }
                                    },
                                    child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 15),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: 2),
                                          color: !widget.clickable
                                              ? color.withOpacity(0.3)
                                              : Colors.black),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Center(
                                          child: Text(
                                              !widget.clickable
                                                  ? 'Status: ${widget.status.toUpperCase()}'
                                                  : 'Request to Join',
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 0.018 *
                                                    MediaQuery.of(buildContext)
                                                        .size
                                                        .height,
                                                color: !widget.clickable
                                                    ? Colors.black
                                                    : Colors.white,
                                                letterSpacing: 1.2,
                                                fontFamily: "Teko",
                                              )),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                //Swipe Button
                Visibility(
                  visible: widget.tf,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 135,
                          width: 25.0,
                          child: RawMaterialButton(
                            hoverColor: Colors.red,
                            fillColor: Colors.black,
                            onPressed: () {},
                            child: Row(
                              children: [
                                Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(math.pi),
                                  child: Icon(
                                    Icons.double_arrow,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),

          //Container visible when class is filled.
          Visibility(
            visible: widget.category == 'student' &&
                widget.documents['maxStud'] == 0,
            child: Container(
              height: 170,
              margin: EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
              ),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already Filled',
                    style: TextStyle(
                        fontFamily: 'Teko',
                        letterSpacing: 1.4,
                        color: Colors.red[400],
                        fontWeight: FontWeight.w900,
                        fontSize: 25),
                  ),
                  Visibility(
                    visible: widget.clickable,
                    child: GestureDetector(
                      onTap: () async {
                        if (widget.clickable == true) {
                          List<Object> lst =
                              List.from(widget.documents['students']);
                          var lt = lst.length + 1;
                          lst.add({
                            'name': '${widget.username}',
                            'email': widget.uemail,
                            'uid': widget.userId,
                            'status': 'waiting',
                            'vac': widget.userVac,
                            'dose': widget.userDose,
                            'count': lt,
                          });

                          await widget.documents.reference.update(
                            {
                              'students': lst,
                            },
                          ).whenComplete(() => setState(() {}));
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 75),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            color: Colors.cyan),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Center(
                            child: Text('Request to Join Online',
                                maxLines: 1,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 0.018 *
                                      MediaQuery.of(buildContext).size.height,
                                  color: Colors.black,
                                  letterSpacing: 1.2,
                                  fontFamily: "Teko",
                                )),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
            ),
          ),
        ],
      ),
    );
  }
}

//Refresh Page.
Future<Null> _refresh_work_history() async {
  Future.delayed(Duration(seconds: 2));
  return null;
}
