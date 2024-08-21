// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hrm_employee/providers/user_provider.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart'; // Custom Dropdown import
import '../../constant.dart';
import 'package:nb_utils/nb_utils.dart';

class TaskEditPage extends StatefulWidget {
  final int id;
  final String taskName;
  final String project;
  final String endDate;
  final String description;
  final String status;

  TaskEditPage({
    required this.id,
    required this.taskName,
    required this.project,
    required this.endDate,
    required this.description,
    required this.status,
  });

  @override
  _TaskEditPageState createState() => _TaskEditPageState();
}

class _TaskEditPageState extends State<TaskEditPage> {
  late TextEditingController _taskNameController;
  late TextEditingController _endDateController;
  late TextEditingController _descrController;
  late String _status;
  String? _project;
  late UserData userData;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  static const Map<String, int> statusId = {
    'In Progress': 0,
    'Completed': 1,
  };

  static const Map<int, String> projectId = {
    1: 'HRMS Old',
    2: 'HRMS New',
    3: 'UI Development',
    4: 'Mobile Development',
  };

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController(text: widget.taskName);
    _endDateController = TextEditingController(text: '');
    _descrController = TextEditingController(text: widget.description);
    _status = widget.status;
    _project = widget.project;


    // Initialize selectedDate and selectedTime if there is time included in widget.endDate
    if (widget.endDate.contains('T')) {
      final parts = widget.endDate.split('T');
      if (parts.length == 2) {
        selectedDate = DateFormat('yyyy-MM-dd').parse(parts[0]);
        selectedTime = TimeOfDay(
          hour: int.parse(parts[1].split(':')[0]),
          minute: int.parse(parts[1].split(':')[1]),
        );
        _endDateController.text =
            DateFormat('yyyy-MM-dd').format(selectedDate!);
      }
    } else {
      selectedDate = DateFormat('yyyy-MM-dd').parse(widget.endDate);
      _endDateController.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
    }
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _endDateController.dispose();
    _descrController.dispose();
    super.dispose();
  }

  Future<void> _updateTask() async {
    if (selectedDate == null) {
      return;
    }

    DateTime endDate = selectedDate!;
    if (selectedTime != null) {
      endDate = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );
    }

    final url = Uri.parse('http://192.168.1.5:3000/task/edit');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${userData.token}',
    };

    final body = json.encode({
      'ID': widget.id,
      'empcode': userData.userID,
      'project': _project,
      'task_name': _taskNameController.text,
      'descr': _descrController.text,
      'end_date': endDate.toIso8601String(), // Ensure to convert to UTC string
      'status': statusId[_status],
    });
    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        toast('Task updated successfully');
      } else {
        print('Failed to update task: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    userData = Provider.of<UserData>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kMainColor,
      appBar: AppBar(
        backgroundColor: kMainColor,
        elevation: 0.0,
        titleSpacing: 0.0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Edit Task',
          maxLines: 2,
          style: kTextStyle.copyWith(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20.0),
          Expanded(
            child: Container(
              width: context.width(),
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20.0),
                     Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Project',
                          style: TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.5),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: CustomDropdown(
                            items: projectId.values.toList(),
                            hintText: 'Select Project',
                            initialItem: _project,
                            onChanged: (newValue) {
                              setState(() {
                                _project = newValue.toString();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Task Name',
                          style: TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        TextField(
                          controller: _taskNameController,
                          decoration: const InputDecoration(
                            // labelText: 'Task Name',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0))),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                  
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Status',
                          style: TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.5),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: CustomDropdown(
                            items: statusId.keys.toList(),
                            hintText: 'Select Status',
                            initialItem: _status,
                            onChanged: (newValue) {
                              setState(() {
                                _status = newValue.toString();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Row(children: [
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          controller: _endDateController,
                          decoration: const InputDecoration(
                            labelText: 'Due Date',
                            labelStyle: TextStyle(fontWeight: FontWeight.bold),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0))),
                            suffixIcon: Icon(Icons.date_range_rounded,
                                color: kGreyTextColor),
                          ),
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                                _endDateController.text =
                                    DateFormat('yyyy-MM-dd')
                                        .format(selectedDate!);
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      ElevatedButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ?? TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedTime = picked;
                              _endDateController.text = DateFormat('yyyy-MM-dd')
                                      .format(selectedDate!) +
                                  ' ' +
                                  selectedTime!.format(context);
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              const Color.fromARGB(255, 85, 125, 244),
                          padding: const EdgeInsets.symmetric(
                              vertical: 23.0, horizontal: 24.0),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: Text(
                          selectedTime != null
                              ? selectedTime!.format(context)
                              : 'Add Time',
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description',
                          style: TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        TextField(
                          controller: _descrController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            // labelText: 'Description',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0))),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: _updateTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kMainColor,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 130.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: const Text(
                        'Update',
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
