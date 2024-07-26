import 'dart:convert';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:hrm_employee/constant.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hrm_employee/providers/user_provider.dart';

class ProjectAssignmentScreen extends StatefulWidget {
  const ProjectAssignmentScreen({Key? key}) : super(key: key);

  @override
  _ProjectAssignmentScreenState createState() =>
      _ProjectAssignmentScreenState();
}

class _ProjectAssignmentScreenState extends State<ProjectAssignmentScreen> {
  late UserData userData;
  final projectNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final deadlineController = TextEditingController();

  TimeOfDay? selectedEndTime;
  DateTime? deadline;

  String selectedLead = 'Alice'; // Example value
  List<String> selectedTeamMembers = [];

  final List<String> allMembers = ['Alice', 'Bob', 'Charlie', 'David'];

  @override
  void dispose() {
    projectNameController.dispose();
    descriptionController.dispose();
    deadlineController.dispose();
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
        title: const Text(
          'Project Assignment',
          maxLines: 2,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20.0),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Project Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          controller: projectNameController,
                          decoration: const InputDecoration(
                            hintText: 'Project Name',
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w400),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
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
                                TimeOfDay? selectedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (selectedTime != null) {
                                  setState(() {
                                    deadline = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      selectedTime.hour,
                                      selectedTime.minute,
                                    );
                                    deadlineController.text =
                                        DateFormat('yyyy-MM-dd HH:mm')
                                            .format(deadline!);
                                  });
                                }
                              }
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0)),
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              suffixIcon: Icon(Icons.date_range_rounded,
                                  color: Colors.grey),
                              labelText: 'Deadline',
                              hintText: 'Select Deadline',
                              hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400),
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
                          'Select Lead',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15.0)),
                          ),
                          child: CustomDropdown(
                            items: ['Alice', 'Bob', 'Charlie']
                                .map((e) => e)
                                .toList(), // Example values
                            hintText: 'Select Lead',
                            onChanged: (newValue) {
                              setState(() {
                                selectedLead = newValue.toString();
                              });
                            },
                            decoration: CustomDropdownDecoration(
                              expandedBorderRadius: BorderRadius.circular(15.0),
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
                          'Select Team Members',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        MultiSelectDialogField(
                          items: allMembers
                              .map((member) => MultiSelectItem(member, member))
                              .toList(),
                          title: const Text(
                            'Select Team Members',
                            style: TextStyle(color: Colors.grey),
                          ),
                          selectedColor: const Color.fromARGB(255, 84, 27, 94),
                          buttonText: const Text('Select Team Members'),
                          onConfirm: (results) {
                            setState(() {
                              selectedTeamMembers =
                                  results.map((e) => e.toString()).toList();
                            });
                          },
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15.0)),
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
                          controller: descriptionController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            hintText: 'Description',
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w400),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 84, 27, 94),
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Text('Assign Project',
                            style: TextStyle(color: Colors.white)),
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
