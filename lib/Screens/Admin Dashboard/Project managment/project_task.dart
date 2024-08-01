import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hrm_employee/GlobalComponents/button_global.dart';
import 'package:hrm_employee/Screens/Admin%20Dashboard/Project%20managment/project_managment.dart';
import 'package:hrm_employee/Screens/Admin%20Dashboard/Project%20managment/project_progress.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:hrm_employee/constant.dart';
import 'package:hrm_employee/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';


class ProjectTaskScreen extends StatefulWidget {
  final Project project;

  ProjectTaskScreen({required this.project});

  @override
  State<ProjectTaskScreen> createState() => _ProjectTaskScreenState();
}

class _ProjectTaskScreenState extends State<ProjectTaskScreen> {
  late UserData userData;
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController taskDescriptionController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  List<String> selectedTeamMembers = [];
  DateTime? deadline;

  static const Map<int, String> statusId = {
    0: 'In Progress',
    1: 'Completed',
  };

  @override
  void dispose() {
    taskNameController.dispose();
    taskDescriptionController.dispose();
    deadlineController.dispose();
    super.dispose();
  }

void applyTask() async {
  int statusInt = statusId.keys
      .firstWhere((key) => statusId[key] == statusId, orElse: () => 0);

  userData = Provider.of<UserData>(context, listen: false);

  Map<String, dynamic> taskValues = {
    'project': widget.project.name,
    'task': taskNameController.text,
    'status': statusInt,
    'description': taskDescriptionController.text,
    'assignee': selectedTeamMembers.join(", "), // Concatenate selected members
    'deadline': deadlineController.text,
  };

  String jsonData = jsonEncode(taskValues);

  String url = 'http://192.168.1.4:3000/task/assignProjectTask';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${userData.token}',
      },
      body: jsonData,
    );

    if (response.statusCode == 200) {
      toast('New Task Added Successfully');
      print('Task posted successfully');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const ProjectManagementScreen()));
    } else {
      print('Failed to post Task: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception while posting Task: $e');
  }
}


 @override
Widget build(BuildContext context) {
  List<String> allMembers = widget.project.teamMembers.toList();
  if (!allMembers.contains(widget.project.teamLead)) {
    allMembers.add(widget.project.teamLead);
  }

  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 84, 27, 94),
    appBar: AppBar(
      backgroundColor: const Color.fromARGB(255, 84, 27, 94),
      elevation: 0.0,
      titleSpacing: 0.0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Text(
        'Assign Task',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
    body: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(60.0),
          topRight: Radius.circular(60.0),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0), // Added top padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: taskNameController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Task Name',
                  labelStyle: const TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: taskDescriptionController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Task Description',
                  labelStyle: const TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: deadlineController,
                readOnly: true,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: deadline ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      deadline = picked;
                      deadlineController.text =
                          DateFormat('yyyy-MM-dd').format(deadline!);
                    });
                  }
                },
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Deadline',
                  labelStyle: const TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
              MultiSelectDialogField(
                items: allMembers
                    .map((member) => MultiSelectItem<String>(member, member))
                    .toList(),
                title: const Text('Team Members'),
                selectedColor: Colors.black,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                buttonIcon: const Icon(
                  Icons.people,
                  color: Colors.black,
                ),
                buttonText: const Text(
                  'Select Team Members',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                onConfirm: (results) {
                  setState(() {
                    selectedTeamMembers = results.cast<String>();
                  });
                },
              ),
              const SizedBox(height: 20.0),
             ButtonGlobal(
                  onPressed: () {
                    String taskName = taskNameController.text;
                    String taskDescription = taskDescriptionController.text;
                    if (taskName.isNotEmpty &&
                        taskDescription.isNotEmpty &&
                        deadline != null &&
                        selectedTeamMembers.isNotEmpty) {
                      applyTask();
                    } else {
                      // Show a validation error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  buttontext: 'Assign Task',
                  buttonDecoration: kButtonDecoration.copyWith(
                      color: const Color.fromARGB(255, 84, 27, 94),
                      borderRadius: BorderRadius.circular(20.0)),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
}