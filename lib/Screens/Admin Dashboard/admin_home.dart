// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:hrm_employee/Screens/Admin%20Dashboard/Attendance_managment/attendance_manage.dart';
import 'package:hrm_employee/Screens/Admin%20Dashboard/Dailywork_managment/dailywork_managment.dart';
import 'package:hrm_employee/Screens/Admin%20Dashboard/Employee_Admin/employee_directory.dart';
import 'package:hrm_employee/Screens/Admin%20Dashboard/Leave_managment/leave_management.dart';
import 'package:hrm_employee/Screens/Admin%20Dashboard/Project%20managment/project_managment.dart';
import 'package:hrm_employee/Screens/Authentication/profile_screen.dart';
import 'package:hrm_employee/Screens/Authentication/sign_in.dart';
import 'package:hrm_employee/Screens/Chat/chat_list.dart';
import 'package:hrm_employee/Screens/Leave%20Management/leave_management_screen.dart';
import 'package:hrm_employee/Screens/Loan/loan_list.dart';
import 'package:hrm_employee/Screens/Notice%20Board/notice_list.dart';
import 'package:hrm_employee/Screens/Notification%20List/notification.dart';
import 'package:hrm_employee/Screens/Notification/notification_screen.dart';
import 'package:hrm_employee/Screens/Outwork%20Submission/outwork_list.dart';
import 'package:hrm_employee/Screens/Salary%20Management/salary_statement_list.dart';
import 'package:hrm_employee/Screens/Outwork%20Submission/daily_work_report.dart';
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
  String designation = "";
  String empCode = "";
  String? photoUrl;
  int notificationCount = 0;
  int presentCount = 0;
  int lateCount = 0;
  int absentCount = 0;
  DateTime selectedDate = DateTime.now();
  DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  List<Map<String, dynamic>> attendanceData = [];
  List<Map<String, dynamic>> filteredAttendanceData = [];

  @override
  void initState() {
    super.initState();
    userData = Provider.of<UserData>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userData.isTokenLoaded) {
        fetchUserName();
        fetchAttendanceData();
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

  Future<void> fetchAttendanceData() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.5:3000/attendance/getAll'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userData.token}',
        },
        body: json.encode({
          'startDate': DateFormat('yyyy-MM-dd').format(startDate),
          'endDate': DateFormat('yyyy-MM-dd').format(endDate),
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<Map<String, dynamic>> attendanceData =
            List<Map<String, dynamic>>.from(jsonData['attendanceRecords']);

        int presentCount = 0;
        int lateCount = 0;
        int absentCount = 0;

        DateTime cutoffTime = DateTime.utc(DateTime.now().year,
            DateTime.now().month, DateTime.now().day, 9, 31);

        for (var record in attendanceData) {
          DateTime? intime;

          if (record['intime'] != null) {
            intime = DateTime.parse(record['intime']);
          }

          if (intime == null) {
            absentCount++;
          } else if (intime.isBefore(cutoffTime)) {
            presentCount++;
          } else if (intime.isAfter(cutoffTime)) {
            lateCount++;
          }
        }

        if (!mounted)
          return; // Check if the widget is still mounted before calling setState

        setState(() {
          this.attendanceData = attendanceData;
          filteredAttendanceData = attendanceData;
          this.presentCount = presentCount;
          this.lateCount = lateCount;
          this.absentCount = absentCount;
        });
      } else {
        throw Exception('Failed to load attendance records');
      }
    } catch (error) {
      if (!mounted)
        return; // Check if the widget is still mounted before showing the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching attendance records: $error')),
      );
    }
  }

  Future<void> fetchNotificationCount() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.5:3000/notification/count'),
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
        Uri.parse('http://192.168.1.5:3000/auth/getUser'),
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
    var userData = Provider.of<UserData>(context, listen: false);
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
      // backgroundColor: kMainColor,
      backgroundColor: const Color.fromARGB(255, 84, 27, 94),
      // drawer: const Drawer(),
      appBar: AppBar(
        // backgroundColor: kMainColor,
        backgroundColor: const Color.fromARGB(255, 84, 27, 94),
        iconTheme: const IconThemeData(color: Colors.white),
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 20.0,
            backgroundImage: photoUrl != null
                ? NetworkImage(photoUrl!)
                : AssetImage('images/emp1.png') as ImageProvider<Object>?,
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
              height: context.height() / 2.2,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)),
                color: Color.fromARGB(255, 84, 27, 94),
              ),
              child: Column(
                children: [
                  Container(
                    height: context.height() / 3.3,
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
                            backgroundImage: photoUrl != null
                                ? NetworkImage(photoUrl!)
                                : AssetImage('assets/emp1.png')
                                    as ImageProvider<Object>?,
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            userName,
                            style: kTextStyle.copyWith(
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            designation,
                            style: kTextStyle.copyWith(color: kGreyTextColor),
                          ),
                          Text(
                            empCode,
                            style: kTextStyle.copyWith(color: kGreyTextColor),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
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
                            child: Center(
                              child: Text(
                                presentCount.toString(),
                                style: kTextStyle.copyWith(
                                    color: Colors.white, fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            'Present',
                            style: kTextStyle.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
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
                            child: Center(
                              child: Text(
                                lateCount.toString(),
                                style: kTextStyle.copyWith(
                                    color: Colors.white, fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            'Late',
                            style: kTextStyle.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
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
                            child: Center(
                              child: Text(
                                absentCount.toString(),
                                style: kTextStyle.copyWith(
                                    color: Colors.white, fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2.0),
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
                                    maxLines: 1,
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
                        // onTap: () => const NoticeList().launch(context),
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
                        onTap: () => const DailyWorkManagementScreen().launch(context),
                        leading: const Image(
                            image: AssetImage('images/outworksubmission.png')),
                        title: Text(
                          'Daily Task Report',
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
                        // onTap: () => const LoanList().launch(context),
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
