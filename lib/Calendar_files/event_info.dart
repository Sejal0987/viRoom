import 'package:flutter/material.dart';

class EventInfo {
  final String id;
  final String subject;
  final String link, username, useremail, userid;
  final List<dynamic> attendeeEmails;
  final bool shouldNotifyAttendees;
  final bool hasConfereningSupport;
  final int startTimeInEpoch;
  final int endTimeInEpoch, maxStud;
  final List<Object> stud;
  EventInfo(
      {@required this.id,
      @required this.subject,
      @required this.useremail,
      @required this.link,
      @required this.attendeeEmails,
      @required this.shouldNotifyAttendees,
      @required this.hasConfereningSupport,
      @required this.startTimeInEpoch,
      @required this.endTimeInEpoch,
      @required this.username,
      @required this.stud,
      @required this.maxStud,
      @required this.userid});

  EventInfo.fromMap(Map snapshot)
      : id = snapshot['id'] ?? '',
        subject = snapshot['subject'] ?? '',
        link = snapshot['link'],
        attendeeEmails = snapshot['emails'] ?? '',
        shouldNotifyAttendees = snapshot['should_notify'],
        hasConfereningSupport = snapshot['has_conferencing'],
        startTimeInEpoch = snapshot['start'],
        username = snapshot['username'],
        stud = snapshot['students'],
        useremail = snapshot['mail'],
        userid = snapshot['uid'],
        maxStud = snapshot['maxStud'],
        endTimeInEpoch = snapshot['end'];

  toJson() {
    return {
      'id': id,
      'subject': subject,
      'username': username,
      'students': stud,
      'link': link,
      'emails': attendeeEmails,
      'should_notify': shouldNotifyAttendees,
      'has_conferencing': hasConfereningSupport,
      'start': startTimeInEpoch,
      'end': endTimeInEpoch,
      'mail': useremail,
      'uid': userid,
      'maxStud': maxStud
    };
  }
}
