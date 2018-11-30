import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const TASKS_COLLECTION = 'users';
const TODO_TASKS_KEY = 'toDoTasks';
const COMPLETED_TASKS_KEY = 'completedTasks';

class FirestoreProxy {
  final FirebaseUser user;
  final State destination;
  final Firestore db = Firestore.instance;
  List<String> completedTasks = new List<String>();
  List<String> upcomingTasks = new List<String>();

  FirestoreProxy({this.user, this.destination}) {
    db.settings(timestampsInSnapshotsEnabled: true, persistenceEnabled: true);
    db.collection(TASKS_COLLECTION).document(this.user.uid).snapshots().listen((documentSnapshot) {
      if(documentSnapshot.exists) {
        this.destination.setState(() {
          this.upcomingTasks = List<String>.from(documentSnapshot.data[TODO_TASKS_KEY]);
          this.completedTasks = List<String>.from(documentSnapshot.data[COMPLETED_TASKS_KEY]);
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

  List<String> getCompletedTasks() {
    return completedTasks;
  }

  List<String> getUpcomingTasks() {
    return upcomingTasks;
  }

  void markAsCompleted(String text) {
    this.upcomingTasks.remove(text);
    this.completedTasks.add(text);
    _updateTasks();
  }

  void markAsUpcoming(String text) {
    this.completedTasks.remove(text);
    this.upcomingTasks.add(text);
    _updateTasks();
  }

  void addUpcomingTask(String text) {
    this.upcomingTasks.add(text);
    _updateTasks();
  }

  void removeCompletedTask(String text) {
    this.completedTasks.remove(text);
    _updateTasks();
  }
}