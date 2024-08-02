// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:hrm_employee/GlobalComponents/button_global.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../constant.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hrm_employee/providers/user_provider.dart';

const baseUrl = 'http://192.168.1.5:3000/images/';

class EmployeeDirectory extends StatefulWidget {
  const EmployeeDirectory({Key? key}) : super(key: key);

  @override
  _EmployeeDirectoryState createState() => _EmployeeDirectoryState();
}

class _EmployeeDirectoryState extends State<EmployeeDirectory> {
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
        Uri.parse('http://192.168.1.5:3000/auth/getAllUser'),
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

 Future<void> fetchUserData(String empCode) async {
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.5:3000/auth/getUser'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${userData.token}',
      },
      body: json.encode({'empcode': empCode}),
    );

    if (response.statusCode == 200) {
      final userDataJson = json.decode(response.body);
      _showDialog(
          context,
          userDataJson['empName'],
          userDataJson['designation'],
          userDataJson['mobile'],
          userDataJson['email'],
          userDataJson['empCode'],
         userDataJson['photo'],
        );
    } else {
      throw Exception('Failed to load user data');
    }
  } catch (error) {
    print('Error fetching user data: $error');
  }
}


 void _showDialog(BuildContext context, String name, String designation, String phoneNumber, String email, String empCode, String imageUrl) {
    TextEditingController nameController = TextEditingController(text: name);
    TextEditingController emailController = TextEditingController(text: email);
    TextEditingController designationController = TextEditingController(text: designation);
    TextEditingController phoneController = TextEditingController(text: phoneNumber);
    TextEditingController empCodeController = TextEditingController(text: empCode);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircleAvatar(
                  radius: 50,
                  backgroundImage: imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : const AssetImage('images/emp1.png') as ImageProvider,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: nameController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                  TextFormField(
                  controller: empCodeController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Employee Code',
                    border: OutlineInputBorder(),
                  ),
                ),
               
                const SizedBox(height: 16),
                TextFormField(
                  controller: designationController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Designation',
                    border: OutlineInputBorder(),
                  ),
                ),
              
                const SizedBox(height: 16),
                  TextFormField(
                  controller: phoneController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
             
                const SizedBox(height: 16),
                  TextFormField(
                  controller: emailController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
               ButtonGlobal(
                  buttontext: 'Back',
                  buttonDecoration: kButtonDecoration.copyWith(
                      color: const Color.fromARGB(255, 84, 27, 94),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20.0),
                      )),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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
        title: Text(
          'Employee Directory',
          maxLines: 2,
          style: kTextStyle.copyWith(
              color: Colors.white, fontWeight: FontWeight.bold),
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
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                              color: kGreyTextColor.withOpacity(0.5)),
                        ),
                        child: ListTile(
                          leading: users[index]['photo'] != null &&
                                  users[index]['photo']!.isNotEmpty
                              ? Image.network(
                                  baseUrl + users[index]['photo'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.error);
                                  },
                                )
                              : Image.asset('images/emp1.png'),
                          title: Text(
                            users[index]['emp_fname']!,
                            style: kTextStyle,
                          ),
                          subtitle: Text(
                            users[index]['designationname']!,
                            style: kTextStyle.copyWith(color: kGreyTextColor),
                          ),
                          onTap: () {
                            fetchUserData(users[index]['empcode']);
                          },
                          trailing: IconButton(
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                size: 15.0,
                              ),
                              onPressed: () {
                            fetchUserData(users[index]['empcode']);
                              },
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