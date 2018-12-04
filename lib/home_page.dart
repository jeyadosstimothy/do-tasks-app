import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do/db_schema.dart';
import 'package:to_do/home_page_presenter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:to_do/scrolling_calendar/scrolling_calendar.dart';

const DATE_LABEL_FORMAT = 'MMM d, y';

String dateToString(DateTime date, String format) => intl.DateFormat(format).format(date);

class HomePage extends StatefulWidget {
  final FirebaseUser firebaseUser;

  HomePage({this.firebaseUser});

  @override
  _HomePageState createState() => _HomePageState(firebaseUser);
}

class _HomePageState extends State<HomePage> implements HomePageViewContract{
  DateTime currentDate = DateTime.now();
  bool tasksReady;
  TaskList upcomingTasks, completedTasks;
  Map<String, TaskList> upcomingTasksMap;
  HomePagePresenter presenter;
  Duration listItemDuration = Duration(milliseconds: 400);
  AnimatedListState upcomingListState, completedListState, datedUpcomingListState;
  String titleText = 'Upcoming Tasks';

  _HomePageState(FirebaseUser firebaseUser){
    this.presenter = HomePagePresenter(this, firebaseUser);
  }

  @override
  void initState() {
    super.initState();
    tasksReady = false;
    presenter.loadTasks();
  }

  @override
  void onLoadTasksComplete(TaskList upcomingTasks, TaskList completedTasks) {
    setState(() {
      this.upcomingTasks = upcomingTasks;
      this.completedTasks = completedTasks;
      this.upcomingTasksMap = upcomingTasks.getDateTaskMap();
      tasksReady = true;
      print('HomePageState.upcomingTasks.length: ${this.upcomingTasks.length}');
      print('$upcomingTasksMap');
    });
  }

  @override
  void onLoadTasksError() {
    print('Error in loading tasks');
  }

  void addUpcomingTask(String taskName, DateTime dateTime) {
    print('in addUpcomingTask $taskName, $dateTime');
    Task task = new Task(taskName, dateTime);
    if(dateTime == null) {
      if(upcomingTasks.length == 0)
      {
        setState(() {
          upcomingTasks.insert(0, task);
        });
      }
      else {
        upcomingTasks.insert(0, task);
        upcomingListState.insertItem(0, duration: listItemDuration);
      }
    }
    else {
      if (upcomingTasksMap.containsKey(task.getDateTime())) {
        upcomingTasksMap[task.getDateTime()].insert(0, task);
        datedUpcomingListState.insertItem(0, duration: listItemDuration);
      }
      else {
        setState(() {
          upcomingTasksMap[task.getDateTime()] = TaskList(tasks: <Task>[task]);
        });
      }
      setState(() {
        upcomingTasks.insert(0, task);
      });
    }
    presenter.updateTasks();
  }

  void addCompletedTask(Task task) {
    if(completedTasks.length == 0) {
      setState(() {
        completedTasks.insert(0, task);
      });
    }
    else {
      completedTasks.insert(0, task);
      completedListState.insertItem(0, duration: listItemDuration);
    }
    presenter.updateTasks();
  }

  void markAsUpcoming(int index) {
    print('Marking $index as upcoming');
    Task task = completedTasks.removeAt(index);
    completedListState.removeItem(
      index,
      (BuildContext context, Animation<double> animation) {
        Text title = Text(task.getTaskName(), style: Theme.of(context).textTheme.subhead);
        return SlideTransition(
          position: Tween(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0)).animate(CurvedAnimation(parent: animation, curve: Interval(0.5, 1.0))),
          child: SizeTransition(
            sizeFactor: CurvedAnimation(parent: animation, curve: Interval(0.0, 1.0)),
            axisAlignment: 0.0,
            child: ListTile(
              key: ValueKey<Widget>(title),
              title: title,
              leading: IconButton(icon: Icon(Icons.check_box), color: Theme.of(context).accentColor, onPressed: null,),
              trailing: IconButton(icon: Icon(Icons.delete), onPressed: null,),
            )
          ),
        );
      },
      duration: listItemDuration
    );
    setState(() {
      upcomingTasks.insert(0, task);
      if(upcomingTasksMap.containsKey(task.getDateTime()))
        upcomingTasksMap[task.getDateTime()].insert(0, task);
      else
        upcomingTasksMap[task.getDateTime()] = TaskList(tasks: <Task>[task]);
    });
    //upcomingListState.insertItem(0, duration: listItemDuration);
    print('completedTasks.length: ${completedTasks.length}');
    presenter.updateTasks();
  }

  void markDatedTaskAsComplete(int index) {
    print('Marking $index as completed');
    Task task;
    setState(() {
      task = upcomingTasksMap[dateToString(currentDate, DATE_NUM_FORMAT)].removeAt(index);
      if(upcomingTasksMap[task.getDateTime()].length==0) {
        upcomingTasksMap.remove(task.getDateTime());
      }
    });
    print('Placeholder task: ${task.getTaskName()}');
    datedUpcomingListState.removeItem(
      index,
          (BuildContext context, Animation<double> animation) {
        Text title = Text(task.getTaskName(), style: Theme.of(context).textTheme.subhead);
        return SlideTransition(
          position: Tween(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0)).animate(CurvedAnimation(parent: animation, curve: Interval(0.5, 1.0))),
          textDirection: TextDirection.rtl,
          child: SizeTransition(
              sizeFactor: CurvedAnimation(parent: animation, curve: Interval(0.0, 1.0)),
              axisAlignment: 0.0,
              child: ListTile(
                key: ValueKey<Widget>(title),
                title: title,
                leading: IconButton(icon: Icon(Icons.check_box_outline_blank), onPressed: null,),
                trailing: IconButton(icon: Icon(Icons.check, color: Theme.of(context).accentColor,), onPressed: null,),
              )
          ),
        );
      },
      duration: listItemDuration,
    );
    setState(() {
      upcomingTasks.remove(task);
      completedTasks.insert(0, task);
    });
    //completedListState.insertItem(0, duration: listItemDuration);
    presenter.updateTasks();
  }

  void markAsComplete(int index) {
    print('Marking $index as completed');
    Task task = upcomingTasks.removeAt(index);
    print('Placeholder task: ${task.getTaskName()}');
    upcomingListState.removeItem(
      index,
      (BuildContext context, Animation<double> animation) {
        Text title = Text(task.getTaskName(), style: Theme.of(context).textTheme.subhead);
        return SlideTransition(
          position: Tween(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0)).animate(CurvedAnimation(parent: animation, curve: Interval(0.5, 1.0))),
          textDirection: TextDirection.rtl,
          child: SizeTransition(
            sizeFactor: CurvedAnimation(parent: animation, curve: Interval(0.0, 1.0)),
            axisAlignment: 0.0,
            child: ListTile(
              key: ValueKey<Widget>(title),
              title: title,
              leading: IconButton(icon: Icon(Icons.check_box_outline_blank), onPressed: null,),
              trailing: IconButton(icon: Icon(Icons.check, color: Theme.of(context).accentColor,), onPressed: null,),
            )
          ),
        );
      },
      duration: listItemDuration,
    );
    setState(() {
      if(task.hasDateTime()) {
        upcomingTasksMap[task.getDateTime()].remove(task);
        if(upcomingTasksMap[task.getDateTime()].length==0) {
          upcomingTasksMap.remove(task.getDateTime());
        }
      }
      completedTasks.insert(0, task);
    });
    //completedListState.insertItem(0, duration: listItemDuration);
    presenter.updateTasks();
  }

  Task removeCompletedTask(int index) {
    print('Removing $index from completed, length: ${completedTasks.length}');
    Task task;
    setState(() {
      task = completedTasks.removeAt(index);
    });
    completedListState.removeItem(
      index,
      (BuildContext context, Animation<double> animation) {
        Text title = Text(task.getTaskName(), style: Theme.of(context).textTheme.subhead);
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Interval(0.0, 1.0)),
          child: SizeTransition(
            sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeIn),
            axisAlignment: 0.0,
            child: ListTile(
              title: title,
              key: ValueKey<Widget>(title),
              leading: IconButton(icon: Icon(Icons.check_box), onPressed: null,),
              trailing: IconButton(icon: Icon(Icons.delete), onPressed: null,),
            )
          ),
        );
      },
      duration: listItemDuration
    );
    print('CompletedList.length: ${completedTasks.length}');
    presenter.updateTasks();
    return task;
  }

  void showClearAllDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Clear all tasks?'),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                SimpleDialogOption(
                  child: const Text('No'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SimpleDialogOption(
                  child: const Text('Yes'),
                  onPressed: () {
                    Navigator.pop(context);
                    while(completedTasks.length > 0){
                      removeCompletedTask(completedTasks.length-1);
                    }
                  },
                ),
              ],
            ),
          ],
        );
      }
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
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 14),
            height: 100,
            child: Column(
              children: <Widget>[
                Text(
                  'Add New Task' + (date != null ? ' due on ' + dateToString(date, DATE_LABEL_FORMAT) : ''),
                  style: Theme.of(context).textTheme.title
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 5.0, right:5.0),
                    child: TextField(
                      autofocus: true,
                      style: Theme.of(context).textTheme.subhead,
                      onSubmitted: (newTaskText) {
                        Navigator.pop(context);
                        addUpcomingTask(newTaskText, date);
                      },
                    )
                  ),
                ),
              ],
            ),
          )
        );
      }
    );
  }

  Iterable<Color> getDateColors(DateTime date) {
    if (this.upcomingTasksMap.containsKey(dateToString(date, DATE_NUM_FORMAT)))
      return <Color> [Colors.red];
    else
      return <Color> [];
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: (!tasksReady)?
        new Center(child: new CircularProgressIndicator()):
        new PageView(
          controller: new PageController(initialPage: 1),
          children: <Widget>[
            new Scaffold(
              appBar: new AppBar(
                backgroundColor: Theme.of(context).canvasColor,
                elevation: 0,
                title: new Center(
                  child: new Text('Completed Tasks', style: Theme.of(context).textTheme.title),
                )
              ),
              body: new AnimatedList(
                initialItemCount: completedTasks.length,
                itemBuilder: (BuildContext context, int index, Animation animation) {
                  print('Building completedListTile $index, length: ${completedTasks.length}');
                  Text title = Text(completedTasks[index].getTaskName(), style: Theme.of(context).textTheme.subhead);
                  completedListState = context.ancestorStateOfType(const TypeMatcher<AnimatedListState>());
                  return FadeTransition(
                    opacity: animation,
                    child: ListTile(
                      key: ValueKey<Widget>(title),
                      title: title,
                      leading: IconButton(
                        icon: Icon(Icons.check_box, color: Theme.of(context).accentColor),
                        onPressed: () => markAsUpcoming(index)
                      ),
                      trailing: IconButton(icon: Icon(Icons.delete), onPressed: () {
                        Task task = removeCompletedTask(index);
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(task.getTaskName() + ' was deleted'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              addCompletedTask(task);
                            }),
                        ));
                      }),
                    )
                  );
                }
              ),
              floatingActionButton: new FloatingActionButton(
                onPressed: showClearAllDialog,
                child: const Icon(Icons.clear)
              ),
            ),
            new Scaffold(
              appBar: new AppBar(
                backgroundColor: Theme.of(context).canvasColor,
                elevation: 0,
                title: new Center(
                  child: new Text('Upcoming Tasks', style: Theme.of(context).textTheme.title),
                )
              ),
              body: new AnimatedList(
                initialItemCount: upcomingTasks.length,
                itemBuilder: (BuildContext context, int index, Animation animation) {
                  print('Building upcomingListTile $index, length: ${upcomingTasks.length}');
                  Text title = Text(upcomingTasks[index].getTaskName(), style: Theme.of(context).textTheme.subhead);
                  upcomingListState = context.ancestorStateOfType(const TypeMatcher<AnimatedListState>());
                  return FadeTransition(
                    opacity: animation,
                    child: ListTile(
                      key: ValueKey<Widget>(title),
                      title: title,
                      leading: IconButton(icon: Icon(Icons.check_box_outline_blank), onPressed: ()=> markAsComplete(index)),
                    )
                  );
                }
              ),
              floatingActionButton: new FloatingActionButton(
                onPressed: showNewTaskBottomSheet,
                child: const Icon(Icons.add)
              ),
            ),
            new Scaffold(
              appBar: new AppBar(
                elevation: 0,
                backgroundColor: Theme.of(context).canvasColor,
                title: new AnimatedSwitcher(
                  duration: listItemDuration,
                  child: new Center(
                    key: ValueKey<DateTime>(currentDate),
                    child: new Text(
                      'Tasks due on ' + dateToString(currentDate, DATE_LABEL_FORMAT),
                      style: Theme.of(context).textTheme.title
                    )
                  )
                ),
                bottom: new PreferredSize(
                  preferredSize: Size.fromHeight(270),
                  child: new ScrollingCalendar(
                    firstDayOfWeek: DateTime.monday,
                    onDateTapped: (DateTime date) {
                      setState(() {
                        currentDate = date;
                        print('currentDate set to $currentDate');
                        print('${dateToString(currentDate, DATE_NUM_FORMAT)}');
                      });
                    },
                    selectedDate: currentDate,
                    colorMarkers: getDateColors,
                  )
                ),
              ),
              body: new AnimatedSwitcher(
                duration: listItemDuration,
                child: new AnimatedList(
                  key: ValueKey<String>('${currentDate.toString()} ${upcomingTasksMap.containsKey(dateToString(currentDate, DATE_NUM_FORMAT))}'),
                  initialItemCount: upcomingTasksMap.containsKey(dateToString(currentDate, DATE_NUM_FORMAT)) ?
                  upcomingTasksMap[dateToString(currentDate, DATE_NUM_FORMAT)].length:
                  0,
                  itemBuilder: (BuildContext context, int index, Animation animation) {
                    print('Building datedUpcomingListTile $index on $currentDate, length: ${upcomingTasksMap[dateToString(currentDate, DATE_NUM_FORMAT)].length}');
                    Text title = Text(upcomingTasksMap[dateToString(currentDate, DATE_NUM_FORMAT)][index].getTaskName(), style: Theme.of(context).textTheme.subhead);
                    datedUpcomingListState = context.ancestorStateOfType(const TypeMatcher<AnimatedListState>());
                    return FadeTransition(
                      opacity: animation,
                      child: ListTile(
                        key: ValueKey<Widget>(title),
                        title: title,
                        leading: IconButton(icon: Icon(Icons.check_box_outline_blank), onPressed: () => markDatedTaskAsComplete(index)),
                      )
                    );
                  }
                )
              ),
              floatingActionButton: new FloatingActionButton(
                onPressed: () => showNewTaskBottomSheet(date: currentDate),
                child: const Icon(Icons.add)
              ),
            )
          ]
        ),
      );
  }
}
