import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:to_do/db_schema.dart';

const TASKS_COLLECTION = 'users';
const TODO_TASKS_KEY = 'toDoTasks';
const COMPLETED_TASKS_KEY = 'completedTasks';
const DATE_NUM_FORMAT = 'yyyy-MM-dd';

String dateToString(DateTime date, String format) => DateFormat(format).format(date);


class FirestoreProxy {
  final FirebaseUser user;
  final State destination;
  final Firestore db = Firestore.instance;
  TaskList completedTasks = new TaskList();
  TaskList upcomingTasks = new TaskList();
  Map<String, TaskList> upcomingTasksMap = new Map<String, TaskList>();

    FirestoreProxy({this.user, this.destination}) {
    db.settings(timestampsInSnapshotsEnabled: true, persistenceEnabled: true);
    db.collection(TASKS_COLLECTION).document(this.user.uid).snapshots().listen((documentSnapshot) {
      if(documentSnapshot.exists) {
        this.destination.setState(() {
          this.upcomingTasks = TaskList.fromJson(documentSnapshot.data[TODO_TASKS_KEY]);
          this.completedTasks = TaskList.fromJson(documentSnapshot.data[COMPLETED_TASKS_KEY]);
          this.upcomingTasksMap = this.upcomingTasks.getDateTaskMap();

        });
      }
    });
  }

  void _updateTasks() {
    db.collection(TASKS_COLLECTION).document(this.user.uid).setData({
      TODO_TASKS_KEY: this.upcomingTasks.toJson(),
      COMPLETED_TASKS_KEY: this.completedTasks.toJson(),
    });
  }

  bool hasTasks(DateTime date) {
    return upcomingTasksMap.containsKey(dateToString(date, DATE_NUM_FORMAT));
  }

  TaskList getCompletedTasks() {
    return completedTasks;
  }

  TaskList getUpcomingTasks({date}) {
    if (date == null)
      return upcomingTasks;
    else {
      if (upcomingTasksMap.containsKey(dateToString(date, DATE_NUM_FORMAT)))
        return upcomingTasksMap[dateToString(date, DATE_NUM_FORMAT)];
      else
        return TaskList();
    }
  }

  void markAsCompleted(Task task) {
    this.upcomingTasks.remove(task);
    this.completedTasks.insert(0, task);
    _updateTasks();
  }

  void markAsUpcoming(Task task) {
    this.completedTasks.remove(task);
    this.upcomingTasks.insert(0, task);
    _updateTasks();
  }

  void addUpcomingTask(String text, {DateTime date}) {
    var dateLabel;
    if(date != null) {
      dateLabel = dateToString(date, DATE_NUM_FORMAT);
    }
    Task task = Task(taskName: text, dateTime: dateLabel);
    this.upcomingTasks.insert(0, task);
    _updateTasks();
  }

  void removeCompletedTask(Task task) {
    this.completedTasks.remove(task);
    _updateTasks();
  }

  void swapUpcomingTasks({@required int oldIndex, @required int newIndex}) {
    if (oldIndex < newIndex) {
      // removing the item at oldIndex will shorten the list by 1.
      newIndex -= 1;
    }
    final element = upcomingTasks.removeAt(oldIndex);
    upcomingTasks.insert(newIndex, element);
    _updateTasks();
  }
}