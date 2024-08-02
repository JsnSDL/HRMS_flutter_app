import 'package:flutter/material.dart';
import 'package:hrm_employee/constant.dart';
import 'package:nb_utils/nb_utils.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hrm_employee/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


class AttendanceStorage extends StatefulWidget {
  const AttendanceStorage({Key? key}) : super(key: key);

  @override
  State<AttendanceStorage> createState() => _AttendanceStorageState();
}

class _AttendanceStorageState extends State<AttendanceStorage> {
  late UserData userData;
  Future<List<Map<String, dynamic>>>? _attendanceData;
  DateTime selectedDate = DateTime.now();
  DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  int presentDays = 0;
  int absentDays = 0;

  @override
  void initState() {
    super.initState();
    userData = Provider.of<UserData>(context, listen: false);

    // Check if token is already loaded
    if (userData.isTokenLoaded) {
      _attendanceData = fetchAttendanceData();
    } else {
      // Add a listener to fetch data when the token is loaded
      userData.addListener(_onTokenLoaded);
    }
  }

  @override
  void dispose() {
    // Remove listener when the widget is disposed
    userData.removeListener(_onTokenLoaded);
    super.dispose();
  }

  void _onTokenLoaded() {
    if (userData.isTokenLoaded) {
      setState(() {
        _attendanceData = fetchAttendanceData();
      });
      // Remove listener after data is fetched
      userData.removeListener(_onTokenLoaded);
    }
  }

  Future<List<Map<String, dynamic>>> fetchAttendanceData() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.5:3000/attendance/get'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userData.token}',
        },
        body: json.encode({
          'empcode': userData.userID,
          'startDate': DateFormat('yyyy-MM-dd').format(startDate),
          'endDate': DateFormat('yyyy-MM-dd').format(endDate),
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> attendanceRecords = jsonData['attendanceRecords'];
        return List<Map<String, dynamic>>.from(attendanceRecords);
      } else {
        throw Exception('Failed to load attendance records');
      }
    } catch (error) {
      print('Error fetching attendance records: $error');
      return [];
    }
  }

  String formatTime(String dateTime) {
    try {
      DateTime parsedDateTime = DateTime.parse(dateTime);
      return DateFormat('h:mm a').format(parsedDateTime);
    } catch (e) {
      return '-';
    }
  }

  String getStatus(Map<String, dynamic> attendance) {
    bool hasCheckIn = attendance['intime'] != null;
    bool hasCheckOut = attendance['outtime'] != null;
    return (hasCheckIn && hasCheckOut) ? 'Present' : 'Absent';
  }

   Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        startDate = DateTime(picked.year, picked.month, 1);
        endDate = DateTime(picked.year, picked.month + 1, 0);
        _attendanceData = fetchAttendanceData();
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    presentDays = 0; // Reset presentDays
    absentDays = 0; // Reset absentDays

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kMainColor,
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Attendance Report',
          style: kTextStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  Text(
                    'Month: ${startDate.month}/${startDate.year}',
                    style: kTextStyle.copyWith(color: Colors.white),
                  ),
                  const SizedBox(width: 4.0),
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.white,
                  ),
                ],
              ),
            ).onTap(() => _selectMonth(context)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _attendanceData = fetchAttendanceData();
          });
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              color: kMainColor,
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                  color: Colors.white,
                ),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _attendanceData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No attendance records found.'));
                    } else {
                      List<Map<String, dynamic>> attendanceList = snapshot.data!;
                      Map<String, List<Map<String, dynamic>>> groupedAttendance = {};

                      // Grouping attendance by date
                      attendanceList.forEach((attendance) {
                        String date = attendance['date'] ?? 'Unknown Date';
                        if (!groupedAttendance.containsKey(date)) {
                          groupedAttendance[date] = [];
                        }
                        groupedAttendance[date]!.add(attendance);
                      });

                      groupedAttendance.forEach((date, attendances) {
                        bool hasCheckedIn = attendances.any((attendance) => attendance['intime'] != null);
                        bool hasCheckedOut = attendances.any((attendance) => attendance['outtime'] != null);
                        if (hasCheckedIn && hasCheckedOut) {
                          presentDays++;
                        } else {
                          absentDays++;
                        }
                      });

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20.0),
                          Material(
                            elevation: 2.0,
                            borderRadius: BorderRadius.circular(20.0),
                            child: Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10.0),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            'Date',
                                            style: kTextStyle.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            'In Time',
                                            style: kTextStyle.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            'Out Time',
                                            style: kTextStyle.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            'Status',
                                            style: kTextStyle.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Divider(
                                      color: kBorderColorTextField,
                                      thickness: 1.0,
                                    ),
                                  ),
                                  ...groupedAttendance.entries.map((entry) {
                                    String date = entry.key;
                                    List<Map<String, dynamic>> attendances = entry.value;

                                    // Assuming there's only one check-in and one check-out entry per date
                                    Map<String, dynamic> checkIn = attendances.firstWhere(
                                      (attendance) => attendance['intime'] != null,
                                      orElse: () => {},
                                    );
                                    Map<String, dynamic> checkOut = attendances.firstWhere(
                                      (attendance) => attendance['outtime'] != null,
                                      orElse: () => {},
                                    );

                                    String inTime = checkIn.isNotEmpty ? formatTime(checkIn['intime']) : '-';
                                    String outTime = checkOut.isNotEmpty ? formatTime(checkOut['outtime']) : '-';

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 10.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                date,
                                                style: kTextStyle.copyWith(
                                                  color: kGreyTextColor,
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                inTime,
                                                style: kTextStyle.copyWith(
                                                  color: kGreyTextColor,
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                outTime,
                                                style: kTextStyle.copyWith(
                                                  color: kGreyTextColor,
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                getStatus(checkIn),
                                                style: kTextStyle.copyWith(
                                                  color: getStatus(checkIn) == 'Present'
                                                      ? Colors.green
                                                      : Colors.redAccent,
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}