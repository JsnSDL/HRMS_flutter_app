import 'package:flutter/material.dart';
import 'package:hrm_employee/GlobalComponents/button_global.dart';
import 'package:hrm_employee/constant.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:hrm_employee/providers/user_provider.dart';
import 'package:nb_utils/nb_utils.dart';

class EditProjectTaskScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  const EditProjectTaskScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<EditProjectTaskScreen> createState() => _EditProjectTaskScreenState();
}

class _EditProjectTaskScreenState extends State<EditProjectTaskScreen> {
  late TextEditingController taskNameController;
  late TextEditingController taskDescriptionController;
  late TextEditingController deadlineController;
  late bool completed;
  late UserData userData;
  DateTime? deadline;

  @override
  void initState() {
    super.initState();
    taskNameController = TextEditingController(text: widget.task['task_name']);
    taskDescriptionController =
        TextEditingController(text: widget.task['description']);
    deadlineController = TextEditingController(
        text: widget.task['deadline'] != null
            ? DateFormat('yyyy-MM-dd')
                .format(DateTime.parse(widget.task['deadline']))
            : '');

    completed = widget.task['completed'] ?? false;
    deadline = widget.task['deadline'] != null
        ? DateTime.parse(widget.task['deadline'])
        : null;
  }

  Future<void> _updateTask() async {
    if (deadline == null) {
      return;
    }

    final url = Uri.parse('http://192.168.1.5:3000/task/editProjectTask');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${userData.token}',
    };

    final body = json.encode({
      'id': widget.task['id'],
      'project': widget.task['project'],
      'task': taskNameController.text,
      'description': taskDescriptionController.text,
      'status': completed ? 1 : 0,
      'deadline': deadline?.toIso8601String(),
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        toast('Task Edited Successfully');
        Navigator.pop(context, {
          'task_name': taskNameController.text,
          'description': taskDescriptionController.text,
          'completed': completed,
          'deadline': deadline?.toIso8601String(),
        });
      } else {
        print('Failed to update task: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  @override
  void dispose() {
    taskNameController.dispose();
    taskDescriptionController.dispose();
    deadlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userData = Provider.of<UserData>(context, listen: false);

    return Scaffold(
      backgroundColor: kMainColor,
      appBar: AppBar(
        backgroundColor: kMainColor,
        elevation: 0.0,
        titleSpacing: 0.0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Edit Task',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0)),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: taskNameController,
                  decoration: const InputDecoration(
                    hintText: 'Task Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: taskDescriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: deadlineController,
                    readOnly: true,
                    onTap: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          deadline = selectedDate;
                          deadlineController.text =
                              DateFormat('yyyy-MM-dd').format(deadline!);
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      suffixIcon:
                          Icon(Icons.date_range_rounded, color: Colors.grey),
                      labelText: 'Deadline',
                      hintText: 'Select Deadline',
                      hintStyle: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Completed'),
                Switch(
                  value: completed,
                  onChanged: (bool value) {
                    setState(() {
                      completed = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              child: ButtonGlobal(
                onPressed: _updateTask,
                buttontext: 'Update Task',
                buttonDecoration: kButtonDecoration.copyWith(
                    color: kMainColor,
                    borderRadius: BorderRadius.circular(20.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
