import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const TASKS_COLLECTION = 'users';
const TODO_TASKS_KEY = 'toDoTasks';
const COMPLETED_TASKS_KEY = 'completedTasks';
const TASK_LABEL = 'task';
const DATE_LABEL = 'datetime';
const DATE_NUM_FORMAT = 'yyyy-MM-dd';

String dateToString(DateTime date, String format) => DateFormat(format).format(date);


class FirestoreProxy {
  final FirebaseUser user;
  final State destination;
  final Firestore db = Firestore.instance;
  List<Map<String, String>> completedTasks = new List<Map<String, String>>();
  List<Map<String, String>> upcomingTasks = new List<Map<String, String>>();
  Map<String, List<Map<String, String>>> upcomingTasksMap = new Map<String, List<Map<String, String>>>();

  List<Map<String, String>> convertToList(var iterable) {
    var x = List<Map<dynamic, dynamic>>.from(iterable);
    return List<Map<String, String>>.from(x.map((mp) => Map<String, String>.from(mp)));
  }

  FirestoreProxy({this.user, this.destination}) {
    db.settings(timestampsInSnapshotsEnabled: true, persistenceEnabled: true);
    db.collection(TASKS_COLLECTION).document(this.user.uid).snapshots().listen((documentSnapshot) {
      if(documentSnapshot.exists) {
        this.destination.setState(() {
          this.upcomingTasks = convertToList(documentSnapshot.data[TODO_TASKS_KEY]);
          this.completedTasks = convertToList(documentSnapshot.data[COMPLETED_TASKS_KEY]);
          upcomingTasksMap.clear();
          for(var item in upcomingTasks) {
            if(upcomingTasksMap.containsKey(item[DATE_LABEL]))
              upcomingTasksMap[item[DATE_LABEL]].add(item);
            else
              upcomingTasksMap[item[DATE_LABEL]] = <Map<String,String>>[item];
          }
        });
      }
    });
  }

  void _updateTasks() {
    db.collection(TASKS_COLLECTION).document(this.user.uid).setData({
      TODO_TASKS_KEY: this.upcomingTasks,
      COMPLETED_TASKS_KEY: this.completedTasks,
    });
  }

  bool hasTasks(DateTime date) {
    return upcomingTasksMap.containsKey(dateToString(date, DATE_NUM_FORMAT));
  }

  List<Map<String, String>> getCompletedTasks() {
    return completedTasks;
  }

  List<Map<String, String>> getUpcomingTasks({date}) {
    if (date == null)
      return upcomingTasks;
    else {
      if (upcomingTasksMap.containsKey(dateToString(date, DATE_NUM_FORMAT)))
        return upcomingTasksMap[dateToString(date, DATE_NUM_FORMAT)];
      else
        return <Map<String, String>> [];
    }
  }

  void markAsCompleted(Map<String, String> task) {
    this.upcomingTasks.remove(task);
    this.completedTasks.add(task);
    _updateTasks();
  }

  void markAsUpcoming(Map<String, String> task) {
    this.completedTasks.remove(task);
    this.upcomingTasks.add(task);
    _updateTasks();
  }

  void addUpcomingTask(String text, {DateTime date}) {
    Map<String, String> mp = new Map<String, String>();
    mp[TASK_LABEL] = text;
    if(date != null) {
      var dateLabel = dateToString(date, DATE_NUM_FORMAT);
      mp[DATE_LABEL] = dateLabel;
    }
    this.upcomingTasks.add(mp);
    _updateTasks();
  }

  void removeCompletedTask(Map<String, String> text) {
    this.completedTasks.remove(text);
    _updateTasks();
  }
}