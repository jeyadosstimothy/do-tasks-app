import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do/firestoreProxy.dart';
import 'package:to_do/scrolling_calendar/scrolling_calendar.dart';

const DATE_LABEL_FORMAT = 'MMM d, y';

class HomePage extends StatefulWidget {
  final FirebaseUser user;
  HomePage({this.user});

  @override
  _HomePageState createState() => _HomePageState(user: user);
}

class _HomePageState extends State<HomePage> {
  FirestoreProxy db;
  TextStyle titleStyle = TextStyle(fontSize: 30.0);
  DateTime currentDate = DateTime.now();

  _HomePageState({FirebaseUser user}) {
    db = FirestoreProxy(user: user, destination: this);
  }

  Widget getCompletedPage() {
    Iterable<ListTile> tiles = db.getCompletedTasks().map((task) {
      return ListTile(
        title: Text(task[TASK_LABEL], style: TextStyle(fontSize: 22)),
        leading: IconButton(
          icon: Icon(Icons.check_box),
          onPressed: () {
            setState(() {
              db.markAsUpcoming(task);
            });
          }
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            setState(() {
              db.removeCompletedTask(task);
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

  void showNewTaskBottomSheet({date}) {
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
                  'Add New Task' + (date != null ? ' on ' + dateToString(date, DATE_LABEL_FORMAT) : ''),
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
                              db.addUpcomingTask(newTaskText, date: date);
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
    Iterable<ListTile> tiles = db.getUpcomingTasks().map((task) {
      return ListTile(
        title: Text(task[TASK_LABEL], style: TextStyle(fontSize: 22)),
        leading: IconButton(
          icon: Icon(Icons.check_box_outline_blank),
          onPressed: () {
            setState(() {
              db.markAsCompleted(task);
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

  Iterable<Color> getDateColors(DateTime date) {
    if (db.hasTasks(date))
      return <Color> [Colors.red];
    else
      return <Color> [];
  }

  Widget getDateUpcomingPage() {
    Iterable<ListTile> tiles = db.getUpcomingTasks(date: currentDate).map((task) {
      return ListTile(
        title: Text(task[TASK_LABEL], style: TextStyle(fontSize: 22)),
        leading: IconButton(
            icon: Icon(Icons.check_box_outline_blank),
            onPressed: () {
              setState(() {
                db.markAsCompleted(task);
              });
            }
        ),
      );
    });
    List<Widget> divided = ListTile.divideTiles(context: context, tiles: tiles).toList();
    divided.insert(0, ListTile(
      title: Text('Tasks on ' + dateToString(currentDate, DATE_LABEL_FORMAT), style: TextStyle(fontSize: 30)),
    ));
    return Scaffold(
      body: ListView(
        children: divided,
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showNewTaskBottomSheet(date: currentDate);
          },
          child: Icon(Icons.add)
      ),
    );
  }

  Widget getCalendarPage() {
    return new Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(300),
        child: AppBar(
          flexibleSpace: Container(
            child: new ScrollingCalendar(
              firstDayOfWeek: DateTime.monday,
              onDateTapped: (DateTime date) {
                setState(() {
                  currentDate = date;
                });
              },
              selectedDate: currentDate,
              colorMarkers: getDateColors,
            ),
            padding: EdgeInsets.only(top: 25),
          )
        )
      ),
      body: getDateUpcomingPage()
      );
  }
  @override
  Widget build(BuildContext context) {
    return PageView(
      children: <Widget>[
        getCompletedPage(),
        getUpcomingPage(),
        getCalendarPage(),
      ],
      controller: PageController(
        initialPage: 1,
      ),
    );
  }
}
