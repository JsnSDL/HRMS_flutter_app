// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:hrm_employee/Screens/Authentication/profile_screen.dart';
import 'package:hrm_employee/Screens/Authentication/sign_in.dart';
import 'package:hrm_employee/Screens/Birthday%20Notification/birthday_notification.dart';
import 'package:hrm_employee/Screens/Chat/chat_list.dart';
import 'package:hrm_employee/Screens/Employee%20Directory/employee_directory_screen.dart';
import 'package:hrm_employee/Screens/Leave%20Management/leave_management_screen.dart';
import 'package:hrm_employee/Screens/Loan/loan_list.dart';
import 'package:hrm_employee/Screens/Notice%20Board/notice_list.dart';
import 'package:hrm_employee/Screens/Notification%20List/notification.dart';
import 'package:hrm_employee/Screens/Notification/notification_screen.dart';
import 'package:hrm_employee/Screens/Outwork%20Submission/outwork_list.dart';
import 'package:hrm_employee/Screens/Outwork%20Submission/outwork_management_screen.dart';
import 'package:hrm_employee/Screens/Salary%20Management/salary_statement_list.dart';
import 'package:hrm_employee/Screens/Work%20Report/Project%20managment/project_managment.dart';
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



class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserData userData;
  String userName = "";
  String designation = "";
  String empCode = "";
  String? photoUrl; 
  int notificationCount = 0;

  @override
  void initState() {
    super.initState();
    userData = Provider.of<UserData>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userData.isTokenLoaded) {
        fetchUserName();
        fetchNotificationCount();
      } else {
        userData.addListener(_userDataListener);
      }
    });
  }

  void _userDataListener() {
    if (!userData.isTokenLoaded) {
      logout(context);
    }
  }

  Future<void> fetchNotificationCount() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.4:3000/notification/count'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userData.token}',
        },
        body: json.encode({
          'receiver_empcode': userData.userID,
        }),
      );

      if (response.statusCode == 200) {
        final count = json.decode(response.body)['notificationCount'];
        setState(() {
          notificationCount = count;
        });
      } else {
        throw Exception('Failed to fetch notification count');
      }
    } catch (error) {
      // Handle error here
    }
  }

  Future<void> fetchUserName() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.4:3000/auth/getUser'),
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
          designation = json.decode(response.body)['designation'];
          empCode = json.decode(response.body)['empCode'];
          photoUrl = json.decode(response.body)['photo'];
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (error) {
      // Handle error here, e.g., show a message to the user
    }
  }

  void logout(BuildContext context) async {
    await userData.clearUserData();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignIn()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  void dispose() {
    userData.removeListener(_userDataListener);
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kMainColor,
      appBar: AppBar(
        backgroundColor: kMainColor,
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          leading:  CircleAvatar(
            radius: 20.0,
          backgroundImage:  photoUrl != null 
        ? NetworkImage(photoUrl!)
        : AssetImage('images/emp1.png') as ImageProvider<Object>?,),
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
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () async {
                  final count = await Navigator.push<int>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Notificationpage(),
                    ),
                  );
                  if (count != null) {
                    setState(() {
                      notificationCount = count;
                    });
                  }
                },
                icon: const Icon(Icons.notifications),
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 10,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$notificationCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            Container(
              height: context.height() / 2.8,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)),
                color: kMainColor,
              ),
              child: Column(
                children: [
                  Container(
                    height: context.height() / 3.2,
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
                          CircleAvatar(
                              radius: 70.0,
                            backgroundImage:  photoUrl != null 
                          ? NetworkImage(photoUrl!)
                          : AssetImage('assets/emp1.png') as ImageProvider<Object>?,),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            userName,
                            style: kTextStyle.copyWith(
                                fontWeight: FontWeight.bold, fontSize: 20.0),

                          ),
                          Text(
                            designation,
                            style: kTextStyle.copyWith(
                                fontWeight: FontWeight.bold, color:Colors.grey),
                          ),
                           Text(
                            empCode,
                            style: kTextStyle.copyWith(
                                fontWeight: FontWeight.bold,color:Colors.grey),
                          ),
                        ],
                      ).onTap(() {
                        // const ProfileScreen().launch(context);
                      }),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     Column(
                  //       children: [
                  //         Container(
                  //           padding: const EdgeInsets.only(
                  //               left: 15.0,
                  //               right: 15.0,
                  //               top: 10.0,
                  //               bottom: 10.0),
                  //           decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(80.0),
                  //             border: Border.all(color: Colors.white),
                  //             gradient: LinearGradient(
                  //               begin: Alignment.topCenter,
                  //               end: Alignment.bottomCenter,
                  //               colors: [
                  //                 Colors.white.withOpacity(0.6),
                  //                 Colors.white.withOpacity(0.0),
                  //               ],
                  //             ),
                  //           ),
                  //           child: Column(
                  //             children: [
                  //               Text(
                  //                 '22',
                  //                 style: kTextStyle.copyWith(
                  //                     color: Colors.white,
                  //                     fontWeight: FontWeight.bold),
                  //               ),
                  //               Text(
                  //                 'days',
                  //                 style:
                  //                     kTextStyle.copyWith(color: Colors.white),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //         const SizedBox(
                  //           height: 2.0,
                  //         ),
                  //         Text(
                  //           'Present',
                  //           style: kTextStyle.copyWith(color: Colors.white),
                  //         ),
                  //       ],
                  //     ),
                  //     Column(
                  //       children: [
                  //         Container(
                  //           padding: const EdgeInsets.only(
                  //               left: 15.0,
                  //               right: 15.0,
                  //               top: 10.0,
                  //               bottom: 10.0),
                  //           decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(80.0),
                  //             border: Border.all(color: Colors.white),
                  //             gradient: LinearGradient(
                  //               begin: Alignment.topCenter,
                  //               end: Alignment.bottomCenter,
                  //               colors: [
                  //                 Colors.white.withOpacity(0.6),
                  //                 Colors.white.withOpacity(0.0),
                  //               ],
                  //             ),
                  //           ),
                  //           child: Column(
                  //             children: [
                  //               Text(
                  //                 '3',
                  //                 style: kTextStyle.copyWith(
                  //                     color: Colors.white,
                  //                     fontWeight: FontWeight.bold),
                  //               ),
                  //               Text(
                  //                 'days',
                  //                 style:
                  //                     kTextStyle.copyWith(color: Colors.white),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //         const SizedBox(
                  //           height: 2.0,
                  //         ),
                  //         Text(
                  //           'Late',
                  //           style: kTextStyle.copyWith(color: Colors.white),
                  //         ),
                  //       ],
                  //     ),
                  //     Column(
                  //       children: [
                  //         Container(
                  //           padding: const EdgeInsets.only(
                  //               left: 15.0,
                  //               right: 15.0,
                  //               top: 10.0,
                  //               bottom: 10.0),
                  //           decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(80.0),
                  //             border: Border.all(color: Colors.white),
                  //             gradient: LinearGradient(
                  //               begin: Alignment.topCenter,
                  //               end: Alignment.bottomCenter,
                  //               colors: [
                  //                 Colors.white.withOpacity(0.6),
                  //                 Colors.white.withOpacity(0.0),
                  //               ],
                  //             ),
                  //           ),
                  //           child: Column(
                  //             children: [
                  //               Text(
                  //                 '5',
                  //                 style: kTextStyle.copyWith(
                  //                     color: Colors.white,
                  //                     fontWeight: FontWeight.bold),
                  //               ),
                  //               Text(
                  //                 'days',
                  //                 style:
                  //                     kTextStyle.copyWith(color: Colors.white),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //         const SizedBox(
                  //           height: 2.0,
                  //         ),
                  //         Text(
                  //           'Absent',
                  //           style: kTextStyle.copyWith(color: Colors.white),
                  //         ),
                  //       ],
                  //     ),
                  //   ],
                  // ),
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
                                const EmployeeManagement().launch(context);
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
                                    'Employee',
                                    style: kTextStyle.copyWith(
                                        color: kTitleColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Attendance',
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
                              const LeaveManagementScreen().launch(context);
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
                                    'Application',
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
                              const ProjectManagementScreen().launch(context);
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
                                    'Project',
                                    maxLines: 2,
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
                          'Salary Statement',
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
                        onTap: () => BirthdayNotificationsPage().launch(context),
                        leading: const Image(
                            image: AssetImage('images/birthday_icon.png')),
                        title: Text(
                          'Birthday Notification',
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
                          'Notice Board',
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
                        onTap: () => const OutManagementScreen().launch(context),
                        leading: const Image(
                            image: AssetImage('images/outworksubmission.png')),
                        title: Text(
                          'Outwork Submission',
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
                          'Loan',
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
