import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:quick_task/helpers/helper_service.dart';
import 'package:quick_task/screens/task_list.dart';
import 'package:quick_task/services/task_service.dart';
import 'package:intl/intl.dart';

class TaskDetails extends StatefulWidget {
  const TaskDetails({super.key});

  @override
  State<TaskDetails> createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dueDateController;
  TaskService taskService = TaskService();
  HelperService helperService = HelperService();
  late Task task;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _dueDateController = TextEditingController();

    Future.delayed(Duration.zero, () {
      final Map<String, dynamic> data =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      task = data['task'] as Task;

     _titleController.text = task.title ?? '';
	 _descriptionController.text = task.description ?? '';
	 _dueDateController.text = task.dueDate != null
		? DateFormat('dd-MM-yyyy').format(task.dueDate)
		: '';

      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task Details',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/quick_task_background.jpg'),
              fit: BoxFit.cover,
              opacity: 0.3,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(30, 20, 30, 10),
                child: TextFormField(
                  controller: _titleController,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Enter Title',
                    labelStyle: const TextStyle(color: Colors.black),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                      borderSide: BorderSide(color: Colors.blueGrey[900]!, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey[900]!, width: 1.0),
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: TextFormField(
                  controller: _descriptionController,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Enter Description',
                    labelStyle: const TextStyle(color: Colors.black),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                      borderSide: BorderSide(color: Colors.blueGrey[900]!, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey[900]!, width: 1.0),
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: TextFormField(
                  controller: _dueDateController,
                  readOnly: true,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Due Date',
                    labelStyle: const TextStyle(color: Colors.black),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                      borderSide: BorderSide(color: Colors.blueGrey[900]!, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey[900]!, width: 1.0),
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.calendar_today,
                        color: Colors.black,
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: task.dueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null && picked != task.dueDate) {
                          setState(() {
                            task.dueDate = DateTime(picked.year, picked.month, picked.day);
                            _dueDateController.text = DateFormat('dd-MM-yyyy').format(task.dueDate);
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                child: ElevatedButton(
                  onPressed: () async {
                    task.title = _titleController.text;
                    task.description = _descriptionController.text;
                    bool existingTask = task.id != null;
                    await taskService.save(task);
                    await AwesomeDialog(
                      context: context,
                      dialogType: DialogType.success,
                      animType: AnimType.rightSlide,
                      title: 'Success',
                      desc:
                          'Task \'${task.title}\' ${existingTask ? 'updated' : 'saved'} successfully!',
                    ).show();
                    if (mounted) {
                      Navigator.of(context).pop(task);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
