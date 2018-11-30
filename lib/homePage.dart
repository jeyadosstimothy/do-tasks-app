import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do/firestoreProxy.dart';

class HomePage extends StatefulWidget {
  final FirebaseUser user;
  HomePage({this.user});

  @override
  _HomePageState createState() => _HomePageState(user: user);
}

class _HomePageState extends State<HomePage> {
  FirestoreProxy db;
  TextStyle titleStyle = TextStyle(fontSize: 30.0);

  _HomePageState({FirebaseUser user}) {
    db = FirestoreProxy(user: user, destination: this);
  }

  Widget getCompletedPage() {
    Iterable<ListTile> tiles = db.getCompletedTasks().map((text) {
      return ListTile(
        title: Text(text, style: TextStyle(fontSize: 22)),
        leading: IconButton(
          icon: Icon(Icons.check_box),
          onPressed: () {
            setState(() {
              db.markAsUpcoming(text);
            });
          }
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            setState(() {
              db.removeCompletedTask(text);
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
                              db.addUpcomingTask(newTaskText);
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
    Iterable<ListTile> tiles = db.getUpcomingTasks().map((text) {
      return ListTile(
        title: Text(text, style: TextStyle(fontSize: 22)),
        leading: IconButton(
          icon: Icon(Icons.check_box_outline_blank),
          onPressed: () {
            setState(() {
              db.markAsCompleted(text);
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
