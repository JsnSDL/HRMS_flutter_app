import 'package:flutter/material.dart';
import 'package:hrm_employee/constant.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hrm_employee/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AttendanceManagementPage extends StatefulWidget {
  const AttendanceManagementPage({Key? key}) : super(key: key);

  @override
  _AttendanceManagementPageState createState() =>
      _AttendanceManagementPageState();
}

class _AttendanceManagementPageState extends State<AttendanceManagementPage> {
  late UserData userData;
  DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  List<Map<String, dynamic>> attendanceData = [];

  late TextEditingController _searchController;
  List<Map<String, dynamic>> filteredAttendanceData = [];

  bool _isSearchOpen = false;

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
        setState(() {
          attendanceData =
              List<Map<String, dynamic>>.from(jsonData['attendanceRecords']);
          filteredAttendanceData = attendanceData;
        });
      } else {
        throw Exception('Failed to load attendance records');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching attendance records: $error')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Simulated user data provider
    userData = Provider.of<UserData>(context, listen: false);
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    fetchAttendanceData();
  }

  void _onSearchChanged() {
    _updateFilteredAttendance(_searchController.text);
  }

  void _updateFilteredAttendance(String query) {
    setState(() {
      filteredAttendanceData = attendanceData
          .where((record) =>
              record['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

String determineStatus(Map<String, dynamic> record) {
  bool hasIntime = record['intime'] != null;
  bool hasOuttime = record['outtime'] != null;

    DateTime parseDateTime(String dateTimeStr) {
    if (dateTimeStr.endsWith('Z')) {
      dateTimeStr = dateTimeStr.substring(0, dateTimeStr.length - 1);
    }
    return DateTime.parse(dateTimeStr);
  }
  if (hasIntime) {
    DateTime intime = parseDateTime(record['intime']);
    DateTime nineThirty = DateTime(intime.year, intime.month, intime.day, 9, 31);
    if (intime.isBefore(nineThirty)) {
      return 'Present';
    } else {
      return 'Late';
    }
  }

  if (hasOuttime) {
    DateTime outtime = DateTime.parse(record['outtime']);
    DateTime sixFortyFive = DateTime(outtime.year, outtime.month, outtime.day, 18, 45);

    if (outtime.isBefore(sixFortyFive)) {
      return 'Present';
    } else {
      return 'Mis-punch';
    }
  }

  return 'Absent';
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 84, 27, 94),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: _isSearchOpen
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
              )
            : const Text(
                'Attendance Management',
                style: TextStyle(color: Colors.white),
              ),
        backgroundColor: const Color.fromARGB(255, 84, 27, 94),
        elevation: 0.0,
        actions: _buildAppBarActions(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20.0),
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Employee Attendance',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredAttendanceData.length,
                    itemBuilder: (context, index) {
                      final record = filteredAttendanceData[index];
                      return AttendanceCard(
                        name: record['name'],
                        status: determineStatus(record),
                        intime: record['intime'] != null
                            ? DateTime.parse(record['intime'])
                            : null,
                        outtime: record['outtime'] != null
                            ? DateTime.parse(record['outtime'])
                            : null,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearchOpen) {
      return [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _isSearchOpen = false;
              _searchController.clear();
              _updateFilteredAttendance('');
            });
          },
        ),
      ];
    } else {
      return [
        // IconButton(
        //   icon: const Icon(Icons.search),
        //   onPressed: () {
        //     setState(() {
        //       _isSearchOpen = true;
        //     });
        //   },
        // ),
        // IconButton(
        //   icon: const Icon(Icons.file_download),
        //   onPressed: _generateAttendanceReport,
        // ),
      ];
    }
  }

  void _generateAttendanceReport() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Attendance Report'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredAttendanceData.length,
                  itemBuilder: (context, index) {
                    final record = filteredAttendanceData[index];
                    return AttendanceCard(
                      name: record['name'],
                      status: record['intime'] != null ? 'Present' : 'Absent',
                      intime: record['intime'] != null
                          ? DateTime.parse(record['intime'])
                          : null,
                      outtime: record['outtime'] != null
                          ? DateTime.parse(record['outtime'])
                          : null,
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class AttendanceCard extends StatelessWidget {
  final String name;
  final String status;
  final DateTime? intime;
  final DateTime? outtime;

  const AttendanceCard({
    Key? key,
    required this.name,
    required this.status,
    this.intime,
    this.outtime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Status: $status',
                    style: TextStyle(
                      color: StatusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (intime != null)
                    Text(
                      'Intime: ${DateFormat('hh:mm a').format(intime!)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 8),
                  if (outtime != null)
                    Text(
                      'Outtime: ${DateFormat('hh:mm a').format(outtime!)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
   StatusColor(String status) {
    switch (status) {
      case 'Present':
        return kGreenColor;
      case 'Absent':
        return Colors.red;
      case 'Mis-punch':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
