import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreProxy {
  final Firestore db = Firestore.instance;
  final String userId, collectionName;

  FirestoreProxy(this.userId, this.collectionName) {
    db.settings(timestampsInSnapshotsEnabled: true, persistenceEnabled: true);
    print('Created FirestoreProxy($userId, $collectionName)');
  }

  Future<DocumentSnapshot> loadTasks() {
    /*db.collection(TASKS_COLLECTION).document(this.firebaseUser.uid).snapshots().listen((documentSnapshot) {
      if(documentSnapshot.exists) {
        this.upcomingTasks = TaskList.fromJson(documentSnapshot.data[TODO_TASKS_KEY]);
        this.completedTasks = TaskList.fromJson(documentSnapshot.data[COMPLETED_TASKS_KEY]);
        this.upcomingTasksMap = this.upcomingTasks.getDateTaskMap();
      }
    });*/
    print('In FirestoreProxy.loadTasks()');
    return db.collection(collectionName).document(userId).get();
  }

   Future<void> updateTasks(Map<String, List<Map<String, String>>> json) {
    return db.collection(collectionName).document(userId).setData(json);
  }

  /*
  bool hasTasks(DateTime date) {
    return upcomingTasksMap.containsKey(dateToString(date, DATE_NUM_FORMAT));
  }

  TaskList getUpcomingTasks({date}) {
    if (date == null)
      return upcomingTasks;
    else {
      if (upcomingTasksMap.containsKey(dateToString(date, DATE_NUM_FORMAT)))
        return upcomingTasksMap[dateToString(date, DATE_NUM_FORMAT)];
      else
        return TaskList();
    }
  }


  void swapUpcomingTasks({@required int oldIndex, @required int newIndex}) {
    if (oldIndex < newIndex) {
      // removing the item at oldIndex will shorten the list by 1.
      newIndex -= 1;
    }
    final element = upcomingTasks.removeAt(oldIndex);
    upcomingTasks.insert(newIndex, element);
    _updateTasks();
  }
  */
}