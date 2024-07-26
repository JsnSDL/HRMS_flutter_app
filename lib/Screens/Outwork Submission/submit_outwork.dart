// ignore_for_file: avoid_print, use_build_context_synchronously, depend_on_referenced_packages, unnecessary_import

import 'dart:convert';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hrm_employee/Screens/Outwork%20Submission/outwork_management_screen.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../GlobalComponents/button_global.dart';
import '../../constant.dart';
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
    // 0: 'Pending',
    0: 'In Progress',
    1: 'Completed',
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

  void applyTask() async {
    int statusInt = statusId.keys
        .firstWhere((key) => statusId[key] == status, orElse: () => 2);
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
      'status': status == 'In Progress' ? 0 : 1,
      'empcode': userData.userID,
    };

    String jsonData = jsonEncode(taskValues);

    String url = 'http://192.168.1.4:3000/task/apply';

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
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const OutManagementScreen()));
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
          style: kTextStyle.copyWith(
              color: Colors.white, fontWeight: FontWeight.bold),
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
                          'Project Name',
                          style: TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          controller: projectController,
                          decoration: const InputDecoration(
                              // labelText: 'Project Name',
                              hintText: 'Enter Project Name',
                               hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0)),
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Task Name',
                          style: TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                              // labelText: 'Task Name',
                              hintText: 'Enter Task Name',
                               hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Department',
                          style: TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color.fromRGBO(192, 190, 190, 1),
                                  width: 1.5),
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(15.0))),
                          child: CustomDropdown(
                            items: departmentId.values.toList(),
                            hintText: 'Select Department',
                            // initialItem: department,
                            onChanged: (newValue) {
                              setState(() {
                                department = newValue
                                    .toString(); // Update department state
                              });
                            },
                            decoration: CustomDropdownDecoration(
                              expandedBorderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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
                              border: Border.all(
                                color: const Color.fromRGBO(192, 190, 190, 1),
                                width: 1.5,
                              ),
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(15.0))),
                          child: CustomDropdown(
                            items: statusId.values.toList(),
                            hintText: 'Select Status',
                            // initialItem:
                            //     status, // Ensure status is correctly initialized
                            onChanged: (newValue) {
                              setState(() {
                                status =
                                    newValue.toString(); // Update status state
                              });
                            },
                            decoration: const CustomDropdownDecoration(
                                expandedBorderRadius:
                                    BorderRadius.all(Radius.circular(20.0))),
                          ),
                        ),
                      ],
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
                                endDateController.text =
                                    DateFormat('yyyy-MM-dd').format(date);
                              }
                            },
                            controller: endDateController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0))),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              suffixIcon: Icon(Icons.date_range_rounded,
                                  color: kGreyTextColor),
                              labelText: 'Due Date',
                              hintText: 'Select Date',
                               hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400),
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
                            backgroundColor: kMainColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: 23.0, horizontal: 24.0),
                            elevation: 4, // Shadow depth
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: Text(
                            selectedEndTime != null
                                ? selectedEndTime!.format(context)
                                : 'Add Time',
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
                          style: TextStyle(
                              fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          controller: descriptionController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                              // labelText: 'Description',
                              hintText: 'Task Description',
                               hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ButtonGlobal(
                        buttontext: 'Save',
                        buttonDecoration: kButtonDecoration.copyWith(
                            color: kMainColor,
                            borderRadius: BorderRadius.circular(20.0)),
                        onPressed: () => applyTask(),
                      ),
                    ),
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
