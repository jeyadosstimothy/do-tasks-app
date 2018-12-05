import 'package:to_do/firestore_proxy.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do/task_model.dart';
import 'package:meta/meta.dart';

abstract class HomePageViewContract {
  void onLoadTasksComplete(TaskList upcomingTasks, TaskList completedTasks);
  void onLoadTasksError();
}

abstract class FirebaseContract {
  void onRefreshTasks();
}

class HomePagePresenter {
  final HomePageViewContract view;
  final FirestoreProxy firestore;

  TaskList upcomingTasks, completedTasks;

  HomePagePresenter(this.view, FirebaseUser firebaseUser): this.firestore = new FirestoreProxy(firebaseUser.uid);

  void loadTasks() {
    firestore.loadTasks().then((documentSnapshot) {
        if(documentSnapshot.exists) {
          upcomingTasks = TaskList.fromJson(documentSnapshot.data[TODO_TASKS_KEY]).reversed();
          completedTasks = TaskList.fromJson(documentSnapshot.data[COMPLETED_TASKS_KEY]).reversed();
          print('Received upcomingTasks length: ${upcomingTasks.length}');
          print('Received completedTasks length: ${completedTasks.length}');
          view.onLoadTasksComplete(upcomingTasks, completedTasks);
        }
        else {
          upcomingTasks = TaskList(tasks: <Task>[
            Task('Welcome to Do'),
            Task('Swipe towards the right to view your completed tasks'),
            Task('Swipe towards the left to view tasks based on due date'),
            Task('Dates are marked with a red dot if there are tasks due on that date', DateTime.now()),
            Task('You can add new tasks if there are no other tasks with the exact same name and date')
          ]);
          completedTasks = TaskList(tasks: <Task>[]);
          firestore.createTaskDocument(<String, dynamic>{
            COMPLETED_TASKS_KEY: completedTasks.reversed().toJson(),
            TODO_TASKS_KEY: upcomingTasks.reversed().toJson()
          });
          view.onLoadTasksComplete(upcomingTasks, completedTasks);
        }
      },
      onError: view.onLoadTasksError
    );
  }

  void updateTasks({@required Task task, @required bool completed, bool removal}) {
    firestore.updateTask(task.toJson(), completed, removal);
  }

  void removeAllCompletedTasks() {
    firestore.removeAllCompletedTasks();
  }
}