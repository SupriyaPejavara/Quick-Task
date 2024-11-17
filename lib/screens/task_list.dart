import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:quick_task/helpers/helper_service.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../main.dart';
import 'package:quick_task/services/task_service.dart';

class Task {
  String? id;
  String title = '';
  DateTime dueDate = DateTime.now();
  bool completed = false;
  String? description = '';
  Task({
    required this.title,
    required this.dueDate,
  });
}

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  List<Task> tasks = [];
  TaskService taskService = TaskService();
  HelperService helperService = HelperService();

  Future<void> fetch() async {
    try {
      await Parse().initialize(applicationId, parseURL,
          clientKey: clientKey, autoSendSessionId: true);

      ParseUser user = await ParseUser.currentUser();

      final queryBuilder = QueryBuilder(ParseObject('Tasks'))
        ..whereEqualTo('user', user.username)
        ..orderByDescending('dueDate');
      final response = await queryBuilder.query();
      List<Task> results = [];
      if (response.success && response.results != null) {
        for (var o in response.results!) {
          Task task = Task(title: o['title'], dueDate: o['dueDate']);
          task.id = o['objectId'];
          task.description = o['description'];
          task.completed = o['completed'];
          results.add(task);
        }
      }
      setState(() {
        tasks = results;
      });
    } catch (e) {
      
    }
  }

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Quick Task'),
    ),
    body: Column(
      children: [
        Container(
          color: Colors.white.withOpacity(0.8),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [              
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.black),
                    onPressed: () async {
                      await Navigator.of(context).pushNamed(
                        '/view-details',
                        arguments: {'task': Task(title: '', dueDate: DateTime.now())},
                      );
                      await fetch();
                    },
                  ),
                  const Text('Add Task', style: TextStyle(color: Colors.black)),
                ],
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.black),
                    onPressed: () async {
                      final ParseUser parseUser = await ParseUser.currentUser();
                      final result = await parseUser.logout();
                      if (result.success) {
                        await AwesomeDialog(
                          context: context,
                          dialogType: DialogType.success,
                          animType: AnimType.rightSlide,
                          title: 'Logout Success',
                          desc: 'You have successfully logged out.',
                        ).show();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/login',
                          (route) => false,
                        );
                      } else {
                        helperService.showMessage(context, 'Error logging out', error: true);
                      }
                    },
                  ),
                  const Text('Logout', style: TextStyle(color: Colors.black)),
                ],
              ),
            ],
          ),
        ),
        
        Expanded(
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/quick_task_background.jpg'),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: InkWell(
                    onTap: () async {
                      await Navigator.of(context).pushNamed(
                        '/view-details',
                        arguments: {'task': task},
                      );
                      await fetch();
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
                      leading: Icon(
                        task.completed ? Icons.alarm_off_rounded : Icons.alarm,
                        color: task.completed
                            ? Colors.green
                            : DateTime.now().compareTo(task.dueDate) > 0
                                ? Colors.red
                                : Colors.black,
                      ),
                      title: Text(task.title),
                      subtitle: Text(task.description ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: DateFormat('dd-MM-yyyy').format(task.dueDate),
                            icon: Icon(
                              task.completed
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: task.completed
                                  ? Colors.green
                                  : DateTime.now().compareTo(task.dueDate) > 0
                                      ? Colors.red
                                      : Colors.black,
                            ),
                            onPressed: () async {
                              task.completed = !task.completed;
                              bool success = await taskService.save(task);
                              await AwesomeDialog(
                                context: context,
                                dialogType: DialogType.success,
                                animType: AnimType.rightSlide,
                                title: 'Success',
                                desc:
                                    'Task ${task.title} is marked ${task.completed ? 'Completed' : 'Incompleted'}!',
                              ).show();
                              if (success) {
                                await fetch();
                              }
                            },
                          ),
                          IconButton(
                            tooltip: DateFormat('dd-MM-yyyy').format(task.dueDate),
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              bool success = await taskService.delete(task.id!);
                              await AwesomeDialog(
                                context: context,
                                dialogType: DialogType.success,
                                animType: AnimType.rightSlide,
                                title: 'Success',
                                desc:
                                    '${task.completed ? 'Completed' : 'Incompleted'} Task ${task.title} is deleted successfully!',
                              ).show();
                              if (success) {
                                await fetch();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}

}
