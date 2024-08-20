import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hrm_employee/Screens/Birthday%20Notification/birthday_card.dart';
import 'package:hrm_employee/constant.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import DateFormat for date and time formatting

import '../../constant.dart';
import 'package:provider/provider.dart';
import 'package:hrm_employee/providers/user_provider.dart';

class Employee {
  final String name;
  final DateTime birthday;
  final String? emplyoeecode;

  Employee({required this.name, required this.birthday,required this.emplyoeecode});

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      name: json['name'],
      birthday: DateTime.parse(json['dob']),
      emplyoeecode: json['empcode'],
    );
  }
}

class BirthdayNotificationsPage extends StatelessWidget {
  late UserData userData;
  final List<Employee> employees = [];

  BirthdayNotificationsPage({Key? key}) : super(key: key);

  Future<void> fetchBirthday() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.5:3000/notification/get'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userData.token}',
        },
        body: json.encode({
          'empcode': userData.userID,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<Employee> fetchedEmployees = (jsonData['dobRecords'] as List)
            .map((data) => Employee.fromJson(data))
            .toList();
        employees.addAll(fetchedEmployees);
      } else {
        print('Failed to fetch tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
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
        title: Text('Birthday Notifications',
            maxLines: 2,
            style: kTextStyle.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          color: Colors.white,
        ),
        child: FutureBuilder(
          future: fetchBirthday(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error fetching data'));
            } else {
              return employees.isEmpty
                  ? const Center(
                      child: Text(
                        'No one has birthday today',
                        style: TextStyle(fontSize: 18.0, color: Colors.grey),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30.0),
                        Expanded(
                          child: ListView.builder(
                            itemCount: employees.length,
                            itemBuilder: (context, index) {
                              return _buildEmployeeTile(
                                  context, employees[index]);
                            },
                          ),
                        ),
                      ],
                    );
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmployeeTile(BuildContext context, Employee employee) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BirthdayCardPage(employee: employee),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            employee.name,
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Birthday: ${employee.birthday.day}/${employee.birthday.month}/${employee.birthday.year}',
              style: const TextStyle(fontSize: 14.0),
            ),
          ),
          leading: Container(
            width: 50.0,
            height: 50.0,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kMainColor,
            ),
            child: const Icon(
              Icons.cake,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
