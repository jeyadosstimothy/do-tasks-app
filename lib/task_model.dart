import 'package:intl/intl.dart';

const TASK_LABEL = 'task';
const DATE_LABEL = 'datetime';
const DATE_NUM_FORMAT = 'yyyy-MM-dd';

class Task {
  final String taskName;
  final DateTime dateTime;

  Task(this.taskName, [this.dateTime]);

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Task &&
              runtimeType == other.runtimeType &&
              taskName == other.taskName &&
              this.hasDateTime() == other.hasDateTime() &&
              (!this.hasDateTime() || (this.hasDateTime() && (this.getDateTime() == other.getDateTime())));

  @override
  int get hashCode =>
      taskName.hashCode ^
      dateTime.hashCode;

  @override
  String toString() {
    return 'Task{taskName: $taskName, dateTime: $dateTime}';
  }

}


class TaskList{
  final List<Task> tasks;
  int length=0;

  TaskList({List<Task> tasks}): this.tasks = (tasks ?? <Task>[]) {
    length = this.tasks.length;
  }

  TaskList.fromJson(List<dynamic> json):
    this.tasks = List<Task>.from(json.map((taskMap) => Task.fromJson(taskMap))) {
    length = this.tasks.length;
  }

  List<Map<String, String>> toJson() =>
    List<Map<String, String>>.from(tasks.map((Task task) => task.toJson()));

  void clear() {
    tasks.clear();
    length = 0;
  }

  void add(Task task) {
    tasks.add(task);
    length = this.tasks.length;
  }

  void remove(Task task) {
    tasks.remove(task);
    length = this.tasks.length;
  }

  void insert(int index, Task task){
    tasks.insert(index, task);
    length = this.tasks.length;
  }

  Task removeAt(int index) {
    Task task = tasks.removeAt(index);
    length = this.tasks.length;
    return task;
  }

  bool contains(Task element) {
    return tasks.contains(element);
  }

  Task operator[](int index) {
    return tasks[index];
  }

  TaskList reversed() {
    return TaskList(tasks: tasks.reversed.toList());
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

  @override
  String toString() {
    return tasks.toString();
  }


}
