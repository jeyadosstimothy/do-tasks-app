import 'package:cloud_firestore/cloud_firestore.dart';

const TASKS_COLLECTION = 'users';
const TODO_TASKS_KEY = 'toDoTasks';
const COMPLETED_TASKS_KEY = 'completedTasks';

class FirestoreProxy {
  final Firestore db = Firestore.instance;
  final String userId, collectionName;

  FirestoreProxy(this.userId): this.collectionName = TASKS_COLLECTION {
    db.settings(timestampsInSnapshotsEnabled: true, persistenceEnabled: true);
  }

  void createTaskDocument(Map<String, dynamic> json) {
    db.collection(collectionName).document(userId).setData(json);
  }

  Future<DocumentSnapshot> loadTasks() {
    print('Firebase: Fetching tasks');
    return db.collection(collectionName).document(userId).get();
  }

  void removeAllCompletedTasks() {
    db.collection(collectionName).document(userId).updateData(<String, dynamic>{
      COMPLETED_TASKS_KEY: <dynamic>[],
    });
  }

  void updateTask(Map<String, String> task, bool completed, [bool removal]) {
    if(removal == null) {
      print('Firebase: Moving $task to ${completed?"completed":"upcoming"}');
      db.collection(collectionName).document(userId).updateData(<String, dynamic>{
        (completed?COMPLETED_TASKS_KEY:TODO_TASKS_KEY): FieldValue.arrayUnion(<dynamic>[task]),
        (completed?TODO_TASKS_KEY:COMPLETED_TASKS_KEY): FieldValue.arrayRemove(<dynamic>[task]),
      });
    }
    else{
      print('Firebase: ${removal?"Removing":"Adding"} task $task');
      db.collection(collectionName).document(userId).updateData(<String, dynamic>{
        (completed?COMPLETED_TASKS_KEY:TODO_TASKS_KEY): (removal)?FieldValue.arrayRemove(<dynamic>[task]):FieldValue.arrayUnion(<dynamic>[task]),
      });
    }
  }
}