// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:hrm_employee/Screens/Admin%20Dashboard/Attendance_managment/attendance_manage.dart';
import 'package:hrm_employee/Screens/Admin%20Dashboard/Leave_managment/leave_management.dart';
import 'package:hrm_employee/Screens/Authentication/profile_screen.dart';
import 'package:hrm_employee/Screens/Authentication/sign_in.dart';
import 'package:hrm_employee/Screens/Chat/chat_list.dart';
import 'package:hrm_employee/Screens/Employee%20Directory/employee_directory_screen.dart';
import 'package:hrm_employee/Screens/Leave%20Management/leave_management_screen.dart';
import 'package:hrm_employee/Screens/Loan/loan_list.dart';
import 'package:hrm_employee/Screens/Notice%20Board/notice_list.dart';
import 'package:hrm_employee/Screens/Notification/notification_screen.dart';
import 'package:hrm_employee/Screens/Outwork%20Submission/outwork_list.dart';
import 'package:hrm_employee/Screens/Salary%20Management/salary_statement_list.dart';
import 'package:hrm_employee/Screens/Work%20Report/daily_work_report.dart';
import 'package:hrm_employee/providers/user_provider.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import '../../GlobalComponents/button_global.dart';
import '../../constant.dart';
import '../Attendance Management/management_screen.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late UserData userData;
  var userName = "";

  @override
  void initState() {
    super.initState();
    userData = Provider.of<UserData>(context, listen: false);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (userData.isTokenLoaded) {
        fetchUserName();
      } else {
        userData.addListener(() {
          if (userData.isTokenLoaded) {
            setState(() {
              fetchUserName();
            });
          }
        });
      }
    });
  }

     Future<void> fetchUserName() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.7:3000/auth/getUser'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userData.token}',
        },
        body: json.encode({
          'empcode': userData.userID,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          userName = json.decode(response.body)['empName'];
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (error) {
      // Handle error here, e.g., show a message to the user
    }
  }

  void logout(BuildContext context) async {
    var userData = Provider.of<UserData>(context, listen: false);
    await userData.clearUserData();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignIn()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // backgroundColor: kMainColor,
      backgroundColor: const Color.fromARGB(255, 84, 27, 94),
      // drawer: const Drawer(),
      appBar: AppBar(
        // backgroundColor: kMainColor,
        backgroundColor: const Color.fromARGB(255, 84, 27, 94),
        iconTheme: const IconThemeData(color: Colors.white),
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(
            radius: 20.0,
            backgroundImage: AssetImage('images/person.jpg'),
          ),
          title: Text(
              'Hi, $userName',
            style: kTextStyle.copyWith(color: Colors.white, fontSize: 12.0),
          ),
          // subtitle: Text(
          //   'Good Morning',
          //   style: kTextStyle.copyWith(
          //       color: Colors.white, fontWeight: FontWeight.bold),
          // ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            Container(
              height: context.height() / 2.5,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)),
                color: kMainColor,
              ),
              child: Column(
                children: [
                  Container(
                    height: context.height() / 4,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30.0),
                          bottomRight: Radius.circular(30.0)),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10.0,
                          ),
                          const CircleAvatar(
                            radius: 60.0,
                            backgroundColor: kMainColor,
                            backgroundImage: AssetImage(
                              'images/emp1.png',
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            userName,
                            style: kTextStyle.copyWith(
                                fontWeight: FontWeight.bold),
                          ),
                          // Text(
                          //   'Employee',
                          //   style: kTextStyle.copyWith(color: kGreyTextColor),
                          // ),
                        ],
                      ).onTap(() {
                        // const ProfileScreen().launch(context);
                      }),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 10.0,
                                bottom: 10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(80.0),
                              border: Border.all(color: Colors.white),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.6),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '22',
                                  style: kTextStyle.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'days',
                                  style:
                                      kTextStyle.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          Text(
                            'Present',
                            style: kTextStyle.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 10.0,
                                bottom: 10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(80.0),
                              border: Border.all(color: Colors.white),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.6),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '3',
                                  style: kTextStyle.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'days',
                                  style:
                                      kTextStyle.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          Text(
                            'Late',
                            style: kTextStyle.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 10.0,
                                bottom: 10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(80.0),
                              border: Border.all(color: Colors.white),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.6),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '5',
                                  style: kTextStyle.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'days',
                                  style:
                                      kTextStyle.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          Text(
                            'Absent',
                            style: kTextStyle.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              onTap: () => const ProfileScreen().launch(context),
              title: Text(
                'Employee Profile',
                style: kTextStyle.copyWith(color: kTitleColor),
              ),
              leading: const Icon(
                FeatherIcons.user,
                color: kMainColor,
              ),
            ),
            ListTile(
              onTap: () => const ChatScreen().launch(context),
              title: Text(
                'Live Video Calling & Charting',
                style: kTextStyle.copyWith(color: kTitleColor),
              ),
              leading: const Icon(
                FeatherIcons.video,
                color: kMainColor,
              ),
            ),
            ListTile(
              onTap: () => const NotificationScreen().launch(context),
              title: Text(
                'Notification',
                style: kTextStyle.copyWith(color: kTitleColor),
              ),
              leading: const Icon(
                FeatherIcons.bell,
                color: kMainColor,
              ),
            ),
            ListTile(
              title: Text(
                'Terms & Conditions',
                style: kTextStyle.copyWith(color: kTitleColor),
              ),
              leading: const Icon(
                Icons.info_outline,
                color: kMainColor,
              ),
            ),
            ListTile(
              title: Text(
                'Privacy Policy',
                style: kTextStyle.copyWith(color: kTitleColor),
              ),
              leading: const Icon(
                FeatherIcons.alertTriangle,
                color: kMainColor,
              ),
            ),
            ListTile(
              title: Text(
                'Logout',
                style: kTextStyle.copyWith(color: kTitleColor),
              ),
              leading: const Icon(
                FeatherIcons.logOut,
                color: kMainColor,
              ),
              onTap: () {
                // Call the logout function when ListTile is tapped
                logout(context);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20.0,
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
                color: Colors.white,
                // color: Colors.blueAccent,
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Material(
                          elevation: 2.0,
                          child: GestureDetector(
                            onTap: () async {
                              // bool isValid = await PurchaseModel().isActiveBuyer(); // commented  out the purchagre model
                              bool isValid = true;
                              if (isValid) {
                                AttendanceManagementPage().launch(context);
                                // ignore: dead_code
                              } else {
                                showLicense(context: context);
                              }
                            },
                            child: Container(
                              width: context.width(),
                              padding: const EdgeInsets.all(10.0),
                              decoration: const BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: Color(0xFFFD72AF),
                                    width: 3.0,
                                  ),
                                ),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Image(
                                      image: AssetImage(
                                          'images/employeeattendace.png')),
                                  Text(
                                    'Attendance',
                                    style: kTextStyle.copyWith(
                                        color: kTitleColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Management',
                                    style: kTextStyle.copyWith(
                                        color: kTitleColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                      Expanded(
                        child: Material(
                          elevation: 2.0,
                          child: GestureDetector(
                            onTap: () {
                              const EmployeeDirectory().launch(context);
                            },
                            child: Container(
                              width: context.width(),
                              padding: const EdgeInsets.all(10.0),
                              decoration: const BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: Color(0xFF7C69EE),
                                    width: 3.0,
                                  ),
                                ),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Image(
                                      image: AssetImage(
                                          'images/employeedirectory.png')),
                                  Text(
                                    'Employee',
                                    style: kTextStyle.copyWith(
                                        color: kTitleColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Directory',
                                    style: kTextStyle.copyWith(
                                        color: kTitleColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Material(
                          elevation: 2.0,
                          child: GestureDetector(
                            onTap: () {
                              const LeaveManagementPage().launch(context);
                            },
                            child: Container(
                              width: context.width(),
                              padding: const EdgeInsets.all(10.0),
                              decoration: const BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: Color(0xFF4ACDF9),
                                    width: 3.0,
                                  ),
                                ),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Image(
                                      image: AssetImage('images/leave.png')),
                                  Text(
                                    'Leave',
                                    style: kTextStyle.copyWith(
                                        color: kTitleColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Management',
                                    style: kTextStyle.copyWith(
                                        color: kTitleColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                      Expanded(
                        child: Material(
                          elevation: 2.0,
                          child: GestureDetector(
                            onTap: () {
                              const DailyWorkReport().launch(context);
                            },
                            child: Container(
                              width: context.width(),
                              padding: const EdgeInsets.all(10.0),
                              decoration: const BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: Color(0xFF02B984),
                                    width: 3.0,
                                  ),
                                ),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Image(
                                      image:
                                          AssetImage('images/workreport.png')),
                                  Text(
                                    'Employee',
                                    maxLines: 2,
                                    style: kTextStyle.copyWith(
                                        color: kTitleColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Profile Management',
                                    style: kTextStyle.copyWith(
                                        color: kTitleColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Material(
                    elevation: 2.0,
                    child: Container(
                      width: context.width(),
                      padding: const EdgeInsets.all(10.0),
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Color(0xFFFD72AF),
                            width: 3.0,
                          ),
                        ),
                        color: Colors.white,
                      ),
                      child: ListTile(
                        onTap: () {
                          const SalaryStatementList().launch(context);
                        },
                        leading: const Image(
                            image: AssetImage('images/salarymanagement.png')),
                        title: Text(
                          'Salary Management',
                          maxLines: 2,
                          style: kTextStyle.copyWith(
                              color: kTitleColor, fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Material(
                    elevation: 2.0,
                    child: Container(
                      width: context.width(),
                      padding: const EdgeInsets.all(10.0),
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Color(0xFF1CC389),
                            width: 3.0,
                          ),
                        ),
                        color: Colors.white,
                      ),
                      child: ListTile(
                        onTap: () => const NoticeList().launch(context),
                        leading: const Image(
                            image: AssetImage('images/noticeboard.png')),
                        title: Text(
                          'Performance Management',
                          maxLines: 2,
                          style: kTextStyle.copyWith(
                              color: kTitleColor, fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Material(
                    elevation: 2.0,
                    child: Container(
                      width: context.width(),
                      padding: const EdgeInsets.all(10.0),
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Color(0xFF7C69EE),
                            width: 3.0,
                          ),
                        ),
                        color: Colors.white,
                      ),
                      child: ListTile(
                        onTap: () => const OutworkList().launch(context),
                        leading: const Image(
                            image: AssetImage('images/outworksubmission.png')),
                        title: Text(
                          'Employee Recognition and Rewards',
                          maxLines: 2,
                          style: kTextStyle.copyWith(
                              color: kTitleColor, fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Material(
                    elevation: 2.0,
                    child: Container(
                      width: context.width(),
                      padding: const EdgeInsets.all(10.0),
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Color(0xFF4ACDF9),
                            width: 3.0,
                          ),
                        ),
                        color: Colors.white,
                      ),
                      child: ListTile(
                        onTap: () => const LoanList().launch(context),
                        leading:
                            const Image(image: AssetImage('images/loan.png')),
                        title: Text(
                          'Employee Communication',
                          maxLines: 2,
                          style: kTextStyle.copyWith(
                              color: kTitleColor, fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
