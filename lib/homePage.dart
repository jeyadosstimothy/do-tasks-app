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
  DateTime currentDate = DateTime.now();

  _HomePageState({FirebaseUser user}) {
    db = FirestoreProxy(user: user, destination: this);
  }

  Widget getCompletedPage() {
    Iterable<ListTile> tiles = db.getCompletedTasks().map((task) {
      return ListTile(
        title: Text(task[TASK_LABEL], style: Theme.of(context).textTheme.subhead),
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
      title: Text('Completed Tasks', style: Theme.of(context).textTheme.title),
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
                  style: Theme.of(context).textTheme.title
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 5.0, right:5.0),
                    child: TextField(
                      autofocus: true,
                      style: Theme.of(context).textTheme.subhead,
                      onSubmitted: (newTaskText) {
                        setState(() {
                          db.addUpcomingTask(newTaskText, date: date);
                          Navigator.pop(context);
                        });
                      },
                    )
                  ),
                ),

              ],
            ),
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 14),
            height: 100,
          )
        );
      }
    );
  }

  Widget getUpcomingPage() {
    Iterable<ListTile> tiles = db.getUpcomingTasks().map((task) {
      return ListTile(
        title: Text(task[TASK_LABEL], style: Theme.of(context).textTheme.subhead),
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
      title: Text('Upcoming Tasks', style: Theme.of(context).textTheme.title),
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

  List<Widget> getDateUpcomingTasks() {
    Iterable<ListTile> tiles = db.getUpcomingTasks(date: currentDate).map((task) {
      return ListTile(
        title: Text(task[TASK_LABEL], style: Theme.of(context).textTheme.subhead),
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
    return ListTile.divideTiles(context: context, tiles: tiles).toList();
  }

  Widget getCalendarPage() {
    return new Scaffold(
      body: CustomScrollView(
        slivers: <Widget> [
          SliverAppBar(
            forceElevated: true,
            title: Text('Tasks on ' +  dateToString(currentDate, DATE_LABEL_FORMAT), style: Theme.of(context).textTheme.title),
            bottom: new PreferredSize(
              preferredSize: Size.fromHeight(270),
              child: new ScrollingCalendar(
                firstDayOfWeek: DateTime.monday,
                onDateTapped: (DateTime date) {
                  setState(() {
                    currentDate = date;
                  });
                },
                selectedDate: currentDate,
                colorMarkers: getDateColors,
              )
            ),
          ),
          SliverList(delegate: SliverChildListDelegate(getDateUpcomingTasks()))
        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showNewTaskBottomSheet(date: currentDate);
        },
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
        getCalendarPage(),
      ],
      controller: PageController(
        initialPage: 1,
      ),
    );
  }
}
