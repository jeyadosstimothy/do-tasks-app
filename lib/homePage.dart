import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


const TASKS_COLLECTION = 'users';
const TODO_TASKS_KEY = 'toDoTasks';
const COMPLETED_TASKS_KEY = 'completedTasks';


class HomePage extends StatefulWidget {
  final FirebaseUser user;

  HomePage({this.user});

  @override
  _HomePageState createState() => _HomePageState(user: this.user);
}


class _HomePageState extends State<HomePage> {
  final FirebaseUser user;
  final Firestore db = Firestore.instance;
  TextStyle titleStyle = TextStyle(fontSize: 30.0);
  List<String> completedItems = new List<String>();
  List<String> toDoItems = new List<String>();

  _HomePageState({this.user}) {
    db.settings(timestampsInSnapshotsEnabled: true, persistenceEnabled: true);
    db.collection(TASKS_COLLECTION).document(this.user.uid).get().then((documentSnapshot) {
      if(documentSnapshot.exists) {
        setState(() {
          toDoItems = List<String>.from(documentSnapshot.data[TODO_TASKS_KEY]);
          completedItems = List<String>.from(documentSnapshot.data[COMPLETED_TASKS_KEY]);
        });
      }
    });
  }

  void _logout() {
    FirebaseAuth.instance.signOut();
  }

  Widget getCompletedPage() {
    Iterable<ListTile> tiles = completedItems.map((text) {
      return ListTile(
        title: Text(text, style: TextStyle(fontSize: 22)),
        leading: IconButton(
          icon: Icon(Icons.check_box),
          onPressed: () {
            setState(() {
              completedItems.remove(text);
              toDoItems.add(text);
              db.collection(TASKS_COLLECTION).document(this.user.uid).setData({
                TODO_TASKS_KEY: toDoItems,
                COMPLETED_TASKS_KEY: completedItems,
              });
            });
          }
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            setState(() {
              completedItems.remove(text);
              db.collection(TASKS_COLLECTION).document(this.user.uid).setData({
                TODO_TASKS_KEY: toDoItems,
                COMPLETED_TASKS_KEY: completedItems,
              });
            });
          }
        ),
      );
    });
    List<Widget> divided = ListTile.divideTiles(context: context, tiles: tiles).toList();
    divided.insert(0, ListTile(
      title: Text('Completed Tasks', style: TextStyle(fontSize: 30)),
    ));
    return Scaffold(
      body: ListView(
        children: divided,
      )
    );
  }

  void showNewTaskBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return new AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 100),
          curve: Curves.decelerate,
          child: Container(
            child: Column(
              children: <Widget>[
                Text(
                  'Add New Task',
                  style: TextStyle(fontSize: 20)
                ),
                Row(
                  children: <Widget> [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left:5.0, right:10.0),
                        child: TextField(
                          autofocus: true,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                          onSubmitted: (newTaskText) {
                            setState(() {
                              toDoItems.add(newTaskText);
                              db.collection(TASKS_COLLECTION).document(this.user.uid).setData({
                                TODO_TASKS_KEY: toDoItems,
                                COMPLETED_TASKS_KEY: completedItems,
                              });
                              Navigator.pop(context);
                            });
                          },
                        )
                      ),
                    ),
                  ]
                )
              ],
            ),
            padding: const EdgeInsets.all(20.0),
            height: 120,
          )
        );
      }
    );
  }
  Widget getUpcomingPage() {
    Iterable<ListTile> tiles = toDoItems.map((text) {
      return ListTile(
        title: Text(text, style: TextStyle(fontSize: 22)),
        leading: IconButton(
          icon: Icon(Icons.check_box_outline_blank),
          onPressed: () {
            setState(() {
              completedItems.add(text);
              toDoItems.remove(text);
              db.collection(TASKS_COLLECTION).document(this.user.uid).setData({
                TODO_TASKS_KEY: toDoItems,
                COMPLETED_TASKS_KEY: completedItems,
              });
            });
          }
        ),
      );
    });
    List<Widget> divided = ListTile.divideTiles(context: context, tiles: tiles).toList();
    divided.insert(0, ListTile(
      title: Text('Upcoming Tasks', style: TextStyle(fontSize: 30)),
    ));
    return Scaffold(
      body: ListView(
        children: divided,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showNewTaskBottomSheet,
        child: Icon(Icons.add)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: <Widget>[
        getCompletedPage(),
        getUpcomingPage(),
      ],
      controller: PageController(
        initialPage: 1,
      ),
    );
  }

}
