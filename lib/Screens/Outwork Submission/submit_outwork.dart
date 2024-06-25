import 'dart:convert';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/button_global.dart';
import '../../constant.dart';
import 'outwork_list.dart';
import 'dart:async';

import 'package:hrm_employee/main.dart';
import 'package:hrm_employee/providers/user_provider.dart';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


class OutworkSubmission extends StatefulWidget {
  const OutworkSubmission({Key? key}) : super(key: key);

  @override
  _OutworkSubmissionState createState() => _OutworkSubmissionState();
}

class _OutworkSubmissionState extends State<OutworkSubmission> {
  late UserData userData;
  final endDateController = TextEditingController();
  final descriptionController = TextEditingController();
  final nameController = TextEditingController();
  final projectController = TextEditingController();
  TimeOfDay? selectedEndTime;

  static const Map<int, String> statusId = {
    0: 'Pending',
    1: 'Completed',
    2: 'In Progress',
  };

  static const Map<int, String> departmentId = {
    1: 'HRMS Old',
    2: 'HRMS New',
    3: 'UI Development',
    4: 'Mobile Development',
  };

  String status = 'In Progress';
  String department = 'HRMS Old';

  DropdownButton<String> getStatusDropdown() {
    List<DropdownMenuItem<String>> dropDownItems = [];
    for (String status in statusId.values) {
      var item = DropdownMenuItem(
        value: status,
        child: Text(status),
      );
      dropDownItems.add(item);
    }
    return DropdownButton(
      items: dropDownItems,
      value: status,
      onChanged: (value) {
        setState(() {
          status = value!;
        });
      },
    );
  }

  DropdownButton<String> getDepartmentDropdown() {
    List<DropdownMenuItem<String>> dropDownItems = [];
    for (String department in departmentId.values) {
      var item = DropdownMenuItem(
        value: department,
        child: Text(department),
      );
      dropDownItems.add(item);
    }
    return DropdownButton(
      items: dropDownItems,
      value: department,
      onChanged: (value) {
        setState(() {
          department = value!;
        });
      },
    );
  }

  void applyTask() async {
    int statusInt = statusId.keys.firstWhere((key) => statusId[key] == status, orElse: () => 2);
    String departmentVal = department;

    DateTime? endDate;
    try {
      endDate = DateFormat('yyyy-MM-dd').parseStrict(endDateController.text);
      if (selectedEndTime != null) {
        endDate = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          selectedEndTime!.hour,
          selectedEndTime!.minute,
        );
      }
    } catch (e) {
      print('Invalid end date format: $e');
      return;
    }

    Map<String, dynamic> taskValues = {
      'project': projectController.text,
      'task_name': nameController.text,
      'dept': departmentVal,
      'create_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'end_date': endDate.toIso8601String(),
      'descr': descriptionController.text,
      'created_by': userData.userID,
      'status': status == 'In Progress' ? null : statusInt,
      'empcode': userData.userID,
    };

    print(taskValues);

    String jsonData = jsonEncode(taskValues);

    String url = 'http://192.168.1.7:3000/task/apply';

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
        print('Task posted successfully');
        toast('Task applied successfully');
      } else {
        print('Failed to post Task: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception while posting Task: $e');
    }
  }

  @override
  void dispose() {
    endDateController.dispose();
    super.dispose();
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
          'Add Task',
          maxLines: 2,
          style: kTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // actions: const [
        //   Image(
        //     image: AssetImage('images/employeesearch.png'),
        //   ),
        // ],
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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20.0),
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: projectController,
                    decoration: kInputDecoration.copyWith(
                      labelText: 'Project Name',
                      hintText: '',
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: nameController,
                    decoration: kInputDecoration.copyWith(
                      labelText: 'Task Name',
                      hintText: '',
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: descriptionController,
                    maxLines: 5,
                    decoration: kInputDecoration.copyWith(
                      labelText: 'Description',
                      hintText: '',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 60.0,
                    child: FormField(
                      builder: (FormFieldState<dynamic> field) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Department',
                            labelStyle: kTextStyle,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(child: getDepartmentDropdown()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 60.0,
                    child: FormField(
                      builder: (FormFieldState<dynamic> field) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Work Type',
                            labelStyle: kTextStyle,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(child: getStatusDropdown()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          textFieldType: TextFieldType.NAME,
                          readOnly: true,
                          onTap: () async {
                            var date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              endDateController.text = DateFormat('yyyy-MM-dd').format(date);
                            }
                          },
                          controller: endDateController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            suffixIcon: Icon(Icons.date_range_rounded, color: kGreyTextColor),
                            labelText: 'Due Date',
                            hintText: '',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      ElevatedButton(
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null && picked != selectedEndTime) {
                            setState(() {
                              selectedEndTime = picked;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color.fromARGB(255, 85, 125, 244), // Text color
                          padding: const EdgeInsets.symmetric(vertical: 23.0, horizontal: 24.0),
                          elevation: 4, // Shadow depth
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: const Text('Add Time'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  ButtonGlobal(
                    buttontext: 'Save',
                    buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
                    onPressed: () => applyTask(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}