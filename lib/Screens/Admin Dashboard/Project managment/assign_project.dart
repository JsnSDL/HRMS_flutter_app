import 'dart:async';
import 'dart:convert';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:hrm_employee/GlobalComponents/button_global.dart';
import 'package:hrm_employee/Screens/Admin%20Dashboard/Project%20managment/project_progress.dart';
import 'package:hrm_employee/constant.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hrm_employee/providers/user_provider.dart';
import 'package:nb_utils/nb_utils.dart';




class Employee {
  final String empcode;
  final String empFname;

  Employee({required this.empcode, required this.empFname});
}

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

  DateTime? deadline;
  Employee? selectedLead;
  List<Employee> allMembers = [];
  List<Employee> selectedTeamMembers = [];


  @override
  void initState() {
    super.initState();
    fetchAllUsers();
  }

  @override
  void dispose() {
    projectNameController.dispose();
    descriptionController.dispose();
    deadlineController.dispose();
    super.dispose();
  }

  Future<void> fetchAllUsers() async {
    userData = Provider.of<UserData>(context, listen: false);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.4:3000/auth/getAllUser'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userData.token}',
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        List<dynamic> data = json.decode(response.body);
        setState(() {
          allMembers = data.map((item) => Employee(
            empcode: item['empcode'],
            empFname: item['emp_fname'],
          )).toList();
          if (allMembers.isNotEmpty) {
            selectedLead = allMembers.first;
          }
        });
      } else {
        throw Exception('Failed to load users data');
      }
    } catch (error) {
      if (!mounted) return;
      print('Error fetching users: $error');
    }
  }

void assignProject() async {
  if (selectedLead == null || selectedTeamMembers.isEmpty) {
    print('Please select a lead and add team members.');
    return;
  }

  final projectValues = {
    'project': projectNameController.text,
    'dept': "",
    'createdby_empcode': userData.userID,
    'companyid': 2,  
    'deadline':deadlineController.text,
    'description':descriptionController.text,
    'status': 0,
    'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
    'team_lead_empcode': selectedLead!.empcode,
    'member_empcodes': selectedTeamMembers.map((e) => e.empcode).toList(),
  };

  final jsonData = jsonEncode(projectValues);

  const url = 'http://192.168.1.4:3000/task/project';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${userData.token}',
      },
      body: jsonData,
    );

    if (response.statusCode == 201) {
      toast('New Project Created!');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProjectProgress(),
        ),
      );
    } else {
      print('Failed to post project: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception while posting project: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    userData = Provider.of<UserData>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 84, 27, 94),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 84, 27, 94),
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
                            items: allMembers
                                .map((e) => e.empFname)
                                .toList(),
                            hintText: 'Select Lead',
                            onChanged: (newValue) {
                              setState(() {
                                selectedLead = allMembers.firstWhere(
                                  (e) => e.empFname == newValue.toString(),
                                  orElse: () => allMembers.first,
                                );
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
                              .map((member) =>
                                  MultiSelectItem(member, member.empFname))
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
                                  results.cast<Employee>().toList();
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
                      child: ButtonGlobal(
                        onPressed: assignProject,
                        buttontext: 'Assign Project',
                        buttonDecoration: kButtonDecoration.copyWith(
                            color: const Color.fromARGB(255, 84, 27, 94),
                            borderRadius: BorderRadius.circular(20.0)),
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
