//Store Event Data to cloud Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Calendar_files/event_info.dart';

final CollectionReference mainCollection =
    FirebaseFirestore.instance.collection('class');

class Storage {
  Future<void> storeEventData(EventInfo eventInfo) async {
    Map<String, dynamic> data = eventInfo.toJson();

    print('DATA:\n$data');

    await mainCollection.add(data).whenComplete(() {
      print("Event added to the database, id: {${eventInfo.id}}");
    }).catchError((e) => print(e));
  }

  Future<void> updateEventData(EventInfo eventInfo) async {
    Map<String, dynamic> data = eventInfo.toJson();

    print('DATA:\n$data');

    await mainCollection.doc().update(data).whenComplete(() {
      print(mainCollection.doc());
      print("Event updated in the database, id: {${eventInfo.id}}");
    }).catchError((e) => print(e));
  }

  Future<void> deleteEvent({@required String id}) async {
    print('Event deleted, id: $id');
  }

  Stream<QuerySnapshot> retrieveEvents() {
    Stream<QuerySnapshot> myClasses =
        mainCollection.orderBy('start').snapshots();

    return myClasses;
  }
}
