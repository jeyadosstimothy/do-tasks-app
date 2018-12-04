import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do/db_schema.dart';
import 'package:to_do/homePagePresenter.dart';
import 'package:intl/intl.dart' as intl;

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
  Map<DateTime, TaskList> upcomingTasksMap;
  HomePagePresenter presenter;
  Duration listItemDuration = Duration(milliseconds: 300);
  AnimatedListState upcomingListState, completedListState;
  String titleText = 'Upcoming Tasks';
  int _page = 1;

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
  void onLoadTasksComplete(TaskList upcomingTasks, TaskList completedTasks, {Map<DateTime, TaskList> upcomingTasksMap}) {
    setState(() {
      this.upcomingTasks = upcomingTasks;
      this.completedTasks = completedTasks;
      this.upcomingTasksMap = upcomingTasksMap;
      tasksReady = true;
      print('HomePageState.upcomingTasks.length: ${this.upcomingTasks.length}');
    });
  }

  @override
  void onLoadTasksError() {
    print('Error in loading tasks');
  }

  void addUpcomingTask(String taskName, DateTime dateTime) {
    Task task = new Task(taskName, dateTime);
    upcomingTasks.insert(0, task);
    upcomingListState.insertItem(0, duration: listItemDuration);
    presenter.updateTasks();
  }

  void addCompletedTask(Task task) {
    completedTasks.insert(0, task);
    completedListState.insertItem(0, duration: listItemDuration);
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
                    leading: Icon(Icons.check_box),
                    trailing: Icon(Icons.delete),
                )
            ),
          );
        },
        duration: listItemDuration
    );
    setState(() {
      upcomingTasks.insert(0, task);
    });
    //upcomingListState.insertItem(0, duration: listItemDuration);
    print('completedTasks.length: ${completedTasks.length}');
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
                leading: Icon(Icons.check_box_outline_blank),
                trailing: Icon(Icons.check),
              )
            ),
          );
        },
        duration: listItemDuration,
    );
    setState(() {
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
                  leading: Icon(Icons.check_box),
                  trailing: Icon(Icons.delete),
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
          appBar: new AppBar(
            backgroundColor: Theme.of(context).canvasColor,
            elevation: 0,
            title: new AnimatedSwitcher(
              duration: listItemDuration,
              child: new Center(
                key: ValueKey<String>(titleText),
                child: new Text(
                titleText,
                style: Theme.of(context).textTheme.title
              )),
            )
          ),
          body: (tasksReady)?
          new PageView(
            controller: PageController(initialPage: _page),
            onPageChanged: (int page) {
              String _titleTextTemp;
              switch(page) {
                case 0:
                  _titleTextTemp = 'Completed Tasks';
                  break;
                case 1:
                  _titleTextTemp = 'Upcoming Tasks';
                  break;
              }
              setState(() {
                titleText = _titleTextTemp;
                _page = page;
              });
            },
            children: <Widget>[
              AnimatedList(
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
              new AnimatedList(
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
              )
            ],
          ):
          new Center(
              child: new CircularProgressIndicator()
          ),
          floatingActionButton: new FloatingActionButton(
              onPressed: (_page==0) ? showClearAllDialog : showNewTaskBottomSheet,
              child: AnimatedCrossFade(
                firstChild: const Icon(Icons.add),
                secondChild: const Icon(Icons.clear),
                crossFadeState: (_page==0)? CrossFadeState.showSecond: CrossFadeState.showFirst,
                duration: listItemDuration
              )
          ),
        );
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

/*
  Iterable<Color> getDateColors(DateTime date) {
    if (this.upcomingTasksMap.containsKey(date))
      return <Color> [Colors.red];
    else
      return <Color> [];
  }

  List<Widget> getDateUpcomingTasks() {
    TaskList taskList = this.upcomingTasksMap[currentDate] ?? new TaskList();
    Iterable<Widget> tiles = taskList.map(
      (Task task) => ListTile(
        title: Text(task.getTaskName(), style: Theme.of(context).textTheme.subhead),
        leading: IconButton(
          icon: Icon(Icons.check_box_outline_blank),
          onPressed: () {
            setState(() {
              controller.markAsCompleted(task);
            });
          }
        ),
      )
    );
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
  }*/
}
