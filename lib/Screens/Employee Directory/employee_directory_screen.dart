// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant.dart';
import 'employee_directory_details.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hrm_employee/providers/user_provider.dart';


class EmployeeDirectory extends StatefulWidget {
  const EmployeeDirectory({Key? key}) : super(key: key);

  @override
  _EmployeeDirectoryState createState() => _EmployeeDirectoryState();
}

class _EmployeeDirectoryState extends State<EmployeeDirectory> {
  late UserData userData;

  List<Map<String, String>> users = [];

  @override
  void initState() {
    super.initState();
    fetchAllUsers();
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
      setState(() {
        users = List<Map<String, String>>.from((json.decode(response.body) as List).map((user) => {
          'empName': user['emp_fname'].toString(),
          'designation': user['designationname'].toString(),
        }));
      });
    } else {
      print('Failed to load users data with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load users data');
    }
  } catch (error) {
    print('Error fetching users: $error');
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
          'Employee Directory',
          maxLines: 2,
          style: kTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20.0,
          ),
          Expanded(
            child: Container(
              width: context.width(),
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                color: Colors.white,
              ),
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: kGreyTextColor.withOpacity(0.5)),
                        ),
                        child: ListTile(
                          leading: Image.asset('images/emp1.png'),
                          title: Text(
                            users[index]['empName']!,
                            style: kTextStyle,
                          ),
                          subtitle: Text(
                            users[index]['designation']!,
                            style: kTextStyle.copyWith(color: kGreyTextColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                    ],
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