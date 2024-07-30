// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hrm_employee/Screens/Admin%20Dashboard/Dailywork_managment/daily_task.dart';
import 'package:hrm_employee/providers/user_provider.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../../constant.dart';

const baseUrl = 'http://192.168.1.5:3000/images/';

class DailyWorkManagementScreen extends StatefulWidget {
  const DailyWorkManagementScreen({Key? key}) : super(key: key);

  @override
  _DailyWorkManagementScreenState createState() =>
      _DailyWorkManagementScreenState();
}

class _DailyWorkManagementScreenState extends State<DailyWorkManagementScreen> {
  late UserData userData;
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    fetchAllUsers();
  }

  Future<void> fetchAllUsers() async {
    userData = Provider.of<UserData>(context, listen: false);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.4:3000/auth/getAllUserTask'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userData.token}',
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          users = List<Map<String, dynamic>>.from(
              json.decode(response.body) as List<dynamic>);
        });
      } else {
        throw Exception('Failed to load users data');
      }
    } catch (error) {
      if (!mounted) return;
      print('Error fetching users: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 84, 27, 94),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 84, 27, 94),
        elevation: 0.0,
        titleSpacing: 0.0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Daily Task Management',
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
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DailyTask(
                                userId: users[index]['empcode'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                                color: kGreyTextColor.withOpacity(0.5)),
                          ),
                          child: ListTile(
                            
                            title: Text(
                              users[index]['emp_fname']!,
                              style: kTextStyle,
                            ),
                            subtitle: Text(
                              users[index]['designationname']!,
                              style: kTextStyle.copyWith(color: kGreyTextColor),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                size: 15.0,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DailyTask(
                                      userId: users[index]['empcode'],
                                    ),
                                  ),
                                );
                                print(users[index]['empcode']);
                              },
                            ),
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
