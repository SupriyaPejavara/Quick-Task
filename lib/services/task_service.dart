import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../main.dart';
import 'package:quick_task/screens/task_list.dart';

//Task class
class TaskService {
  //fetch tasks from the server
  Future<bool> save(Task task) async {
    try {
      await Parse().initialize(applicationId, parseURL,
          clientKey: clientKey, autoSendSessionId: true);

      ParseUser user = await ParseUser.currentUser();

      final parseObject = ParseObject('Tasks')
        ..set<String?>('user', user.username)
        ..set<String>('title', task.title)
        ..set<DateTime>('dueDate', task.dueDate)
        ..set<String>('description', task.description!)
        ..set<bool>('completed', task.completed);
      if (task.id != null) {
        parseObject.set<String>('objectId', task.id!);
      }

      final response = await parseObject.save();
      return response.success;
    } catch (e) {
      return false;
    }
  }

  //fetch tasks from the server
  Future<bool> delete(String id) async {
    try {
      await Parse().initialize(applicationId, parseURL,
          clientKey: clientKey, autoSendSessionId: true);
      ParseUser user = await ParseUser.currentUser();
      final parseObject = ParseObject('Tasks')
        ..set<String>('objectId', id)
        ..set('user', user.username);
      final response = await parseObject.delete();
      return response.success;
    } catch (e) {
      return false;
    }
  }
}
