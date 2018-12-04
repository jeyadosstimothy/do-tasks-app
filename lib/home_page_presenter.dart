import 'package:to_do/firestore_proxy.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do/db_schema.dart';

const TASKS_COLLECTION = 'users';
const TODO_TASKS_KEY = 'toDoTasks';
const COMPLETED_TASKS_KEY = 'completedTasks';

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

  HomePagePresenter(this.view, FirebaseUser firebaseUser): this.firestore = new FirestoreProxy(firebaseUser.uid, TASKS_COLLECTION);

  void loadTasks() {
    print('In HomePageController.loadTasks()');
    firestore.loadTasks().then((documentSnapshot) {
        upcomingTasks = TaskList.fromJson(documentSnapshot.data[TODO_TASKS_KEY]);
        completedTasks = TaskList.fromJson(documentSnapshot.data[COMPLETED_TASKS_KEY]);
        print('upcomingTasks length: ${upcomingTasks.length}');
        print('completedTasks length: ${completedTasks.length}');
        view.onLoadTasksComplete(upcomingTasks, completedTasks);
      },
      onError: view.onLoadTasksError
    );
  }

  Map<String, List<Map<String, String>>> getDocument() {
    return {
      TODO_TASKS_KEY: upcomingTasks.toJson(),
      COMPLETED_TASKS_KEY: completedTasks.toJson(),
    };
  }

  void updateTasks() {
    firestore.updateTasks(this.getDocument());
  }
}