import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

const DATE_LABEL_FORMAT = 'MMM d, y';

String dateToString(DateTime date, String format) => intl.DateFormat(format).format(date);
const Duration FADE_DURATION = Duration(milliseconds: 300);
const Duration LISTTILE_DURATION = Duration(milliseconds: 350);

class MainScaffold extends StatelessWidget {
  final BuildContext context;
  final Widget title;
  final Widget leading;
  final List<Widget> actions;
  final Widget body;
  final PreferredSizeWidget bottom;
  final FloatingActionButton floatingActionButton;

  MainScaffold({this.context, this.title, this.leading, this.actions, this.body, this.bottom, this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
            backgroundColor: Theme.of(context).canvasColor,
            elevation: 0,
            title: new Center(child: title),
            leading: leading,
            actions: actions,
            bottom: bottom
        ),
        body: body,
        floatingActionButton: floatingActionButton,
    );
  }
}

class NewTaskScreen extends StatefulWidget {
  final DateTime date;
  final AddNewTaskCallback onComplete;

  NewTaskScreen({this.date, this.onComplete});

  @override
  State createState() => NewTaskScreenState(this.date, this.onComplete);
}

typedef void AddNewTaskCallback(String newTaskName, DateTime newTaskDate);

class NewTaskScreenState extends State<NewTaskScreen> {
  String newTaskName = '';
  DateTime newTaskDate;
  final AddNewTaskCallback onComplete;

  NewTaskScreenState(this.newTaskDate, this.onComplete);

  @override
  Widget build(BuildContext context) {
    return new MainScaffold(
        title: new Text(
          'Add New Task',
          style: Theme.of(context).textTheme.title,
        ),
        leading: IconButton(
            icon: Icon(Icons.close, color: Theme.of(context).accentColor),
            onPressed: () => Navigator.pop(context)
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.check, color: Theme.of(context).accentColor),
              onPressed: () {
                if(newTaskName == '') {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return new AlertDialog(
                          title: const Text('Alert'),
                          content: const Text('Your Task should have a name'),
                          actions: <Widget>[
                            new SimpleDialogOption(
                              child: const Text('Close'),
                              onPressed: () => Navigator.pop(context),
                            )
                          ],
                        );
                      }
                  );
                }
                else
                {
                  Navigator.pop(context);
                  onComplete(newTaskName, newTaskDate);
                }
              }
          )
        ],
        body: Column(
          children: <Widget>[
            Container(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  decoration: InputDecoration.collapsed(hintText: 'Task Name'),
                  style: Theme.of(context).textTheme.title,
                  onChanged: (enteredText) {
                    setState(() {
                      newTaskName = enteredText;
                    });
                  },
                  onSubmitted: (enteredText) {
                    setState(() {
                      newTaskName = enteredText;
                    });
                  },
                )
            ),
            Container(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: <Widget>[
                    AnimatedSwitcher(
                        duration: FADE_DURATION,
                        child: Text(
                            (newTaskDate == null) ? 'No due date' : 'Due date: ${dateToString(newTaskDate, DATE_LABEL_FORMAT)}',
                            key: UniqueKey(),
                            style: Theme.of(context).textTheme.subhead
                        )
                    ),
                    Expanded(child: Container()),
                    IconButton(
                        icon: Icon(Icons.calendar_today, color: Theme.of(context).accentColor),
                        onPressed: () {
                          showDatePicker(
                              context: context,
                              initialDate: newTaskDate ?? DateTime.now(),
                              firstDate: DateTime(2000, 1, 1),
                              lastDate: DateTime(2100, 1, 1)
                          ).then((enteredDate) {
                            setState(() {
                              newTaskDate = enteredDate;
                            });
                          });
                        }
                    )
                  ],
                )
            )
          ],
        )
    );
  }
}