import 'package:meta/meta.dart';
import 'package:intl/intl.dart';

const TODO_TASKS_KEY = 'toDoTasks';
const COMPLETED_TASKS_KEY = 'completedTasks';
const TASK_LABEL = 'task';
const DATE_LABEL = 'datetime';
const DATE_NUM_FORMAT = 'yyyy-MM-dd';

class Task {
  final String taskName;
  final DateTime dateTime;

  Task({@required this.taskName, String dateTime}):
    this.dateTime = ((dateTime == null) ? null : DateTime.parse(dateTime));

  Task.fromJson(Map<dynamic, dynamic> json):
    taskName=json[TASK_LABEL].toString(),
    this.dateTime = (json.containsKey(DATE_LABEL) ? DateTime.parse(json[DATE_LABEL].toString()) : null);

  Map<String, String> toJson() {
    var x = {TASK_LABEL: taskName};
    if(dateTime != null)
      x[DATE_LABEL]= getDateTime();
    return x;
  }

  bool hasDateTime() => (dateTime != null);

  String getTaskName() => taskName;
  String getDateTime({String format=DATE_NUM_FORMAT}) {
    assert(hasDateTime());
    return DateFormat(format).format(dateTime);
  }
}


class TaskList{
  final List<Task> tasks;

  TaskList({tasks}): this.tasks = tasks ?? <Task>[];

  TaskList.fromJson(List<dynamic> json):
    this.tasks = List<Task>.from(json.map((taskMap) => Task.fromJson(taskMap)));

  List<Map<String, String>> toJson() =>
    List<Map<String, String>>.from(tasks.map((task)=>task.toJson()));

  void add(Task task) => tasks.add(task);

  void remove(Task task) => tasks.remove(task);

  void insert(int index, Task task) => tasks.insert(index, task);

  Task removeAt(int index) => tasks.removeAt(index);

  Task operator[](int index) {
    return tasks[index];
  }

  Iterable<T> map<T>(T f(Task element)) => tasks.map(f);

  Map<String, TaskList> getDateTaskMap() {
    Map<String, TaskList> taskMap = new Map<String, TaskList>();
    for(var task in tasks) {
      if(task.hasDateTime()) {
        if (taskMap.containsKey(task.getDateTime()))
          taskMap[task.getDateTime()].add(task);
        else
          taskMap[task.getDateTime()] = TaskList(tasks: <Task>[task]);
      }
    }
    return taskMap;
  }
}
