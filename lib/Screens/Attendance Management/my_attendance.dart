import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hrm_employee/constant.dart';
import 'package:hrm_employee/providers/user_provider.dart';
import 'package:hrm_employee/services/location_util.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

class MyAttendance extends StatefulWidget {
  const MyAttendance({
    Key? key,
  }) : super(key: key);

  @override
  _MyAttendanceState createState() => _MyAttendanceState();
}

class _MyAttendanceState extends State<MyAttendance> {
  bool isOffice = true;
  late Timer _timer;
  late DateTime _currentTime;
  late String formattedDate;
  late String intime;
  String locationName = '';
  late String dayOfWeek;
  bool isCheckedIn = false;
  late UserData userData;
  String? checkedInTime;

  List<Map<String, String>> attendanceRecords = [];
  

  @override
  void initState() {
    super.initState();
    intime = '';
    _updateTime();
    _startTimer();
    _loadIntime(); // Load the check-in time from SharedPreferences
  }

  void _loadIntime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      intime = prefs.getString('intime') ?? '';
      isCheckedIn = intime.isNotEmpty;
    });
  }

 void _saveIntime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    prefs.setString('intime', currentTime);
    setState(() {
      intime = currentTime;
      isCheckedIn = true;
    });
  }

   void _clearIntime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('intime');
    setState(() {
      intime = '';
      isCheckedIn = false;
    });
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateTime.now();
      formattedDate = DateFormat('dd-MMM-yyyy').format(_currentTime);
      dayOfWeek = DateFormat('EEEE').format(_currentTime);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> getLocationName(double latitude, double longitude) async {
    final url = 'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json';

    try {
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          locationName = data['display_name'];
        });
      } else {
        throw Exception('Failed to fetch location data from OpenStreetMap Nominatim API');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAttendanceData() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.7:3000/attendance/get'),
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

void checkIn() async {
  if (intime.isEmpty) {
    _saveIntime();
  }

  List<Map<String, dynamic>> todayAttendance = await fetchAttendanceData();

 String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
   bool hasCheckedInToday = todayAttendance.any((record) {
    DateTime recordDate = DateTime.parse(record['exactdate']);
    String recordFormattedDate = DateFormat('yyyy-MM-dd').format(recordDate);
    return recordFormattedDate == formattedDate;
  });

  if (hasCheckedInToday) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You have already checked in for today.'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  Map<String, double?>? location = await LocationUtil.getLocation(context);

  if (location == null || location['latitude'] == null || location['longitude'] == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to retrieve location. Please try again.'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  double latitude = location['latitude']!;
  double longitude = location['longitude']!;

  await getLocationName(latitude, longitude);

  toast('You have been checkedIn');
  setState(() {
    isCheckedIn = true;
  });
}

  void checkOut() async {
    String outime = '${_currentTime.year}-${_currentTime.month}-${_currentTime.day} ${_currentTime.hour}:${_currentTime.minute}:${_currentTime.second}';

    List<Map<String, dynamic>> todayAttendance = await fetchAttendanceData();

     String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
   bool hasCheckedInToday = todayAttendance.any((record) {
    DateTime recordDate = DateTime.parse(record['exactdate']);
    String recordFormattedDate = DateFormat('yyyy-MM-dd').format(recordDate);
    return recordFormattedDate == formattedDate;
  });

  if (hasCheckedInToday) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You have already checked out for today.'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }


    Map<String, double?>? location = await LocationUtil.getLocation(context);

    if (location == null || location['latitude'] == null || location['longitude'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to retrieve location. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    double latitude = location['latitude']!;
    double longitude = location['longitude']!;

   
    await getLocationName(latitude, longitude);

    Map<String, dynamic> attendanceData = {
      'date': formattedDate,
      'time': outime,
      'isCheckIn': 0,
      'latitude': latitude,
      'longitude': longitude,
    };

    setState(() {
      isCheckedIn = false;
    });

    attendanceValues(outime: outime);
  }

  void attendanceValues({required String outime}) async {
    Map<String, dynamic> attendanceValues = {
      'companyID': '10',
      'empcode': userData.userID,
      'exactdate': formattedDate,
      'intime': intime,
      'outtime': outime,
      'location': locationName,
    };

    String jsonData = jsonEncode(attendanceValues);

    String url = 'http://192.168.1.7:3000/attendance/time';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userData.token}',
        },
        body: jsonData,
      );

      if (response.statusCode == 200) {
        print('Out time posted successfully');
        toast('You have been checkedOut');
        _clearIntime();
      } else {
        print('Failed to post out time: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception while posting out time: $e');
    }
  }

  void showCheckInSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please check in first.'),
        duration: Duration(seconds: 2),
      ),
    );
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
        iconTheme:const IconThemeData(color: Colors.white),
        title: Text(
          'My Attendance',
          maxLines: 2,
          style: kTextStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20.0),
          Expanded(
            child: Container(
              width: context.width(),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                color: kBgColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: context.width(),
                    padding: const EdgeInsets.all(14.0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                      color: Colors.white,
                    ),

                  ),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      width: context.width(),
                      padding: const EdgeInsets.all(30.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Choose your Attendance mode',
                            style: kTextStyle.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10.0),
                          Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              color: kMainColor,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.0),
                                    color: isOffice ? Colors.white : kMainColor,
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: kMainColor,
                                        child: Icon(
                                          Icons.check,
                                          color: isOffice ? Colors.white : kMainColor,
                                        ),
                                      ),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        'Office',
                                        style: kTextStyle.copyWith(
                                          color: isOffice ? kTitleColor : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12.0),
                                    ],
                                  ),
                                ).onTap(() {
                                  setState(() {
                                    isOffice = true;
                                  });
                                }),
                                Container(
                                  padding: const EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.0),
                                    color: !isOffice ? Colors.white : kMainColor,
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: kMainColor,
                                        child: Icon(
                                          Icons.check,
                                          color: !isOffice ? Colors.white : kMainColor,
                                        ),
                                      ),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        'Outside',
                                        style: kTextStyle.copyWith(
                                          color: !isOffice ? kTitleColor : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12.0),
                                    ],
                                  ),
                                ).onTap(() {
                                  setState(() {
                                    isOffice = false;
                                  });
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30.0),
                          Text(
                            _currentTime.hour < 12 ? "Good Morning"
                                : _currentTime.hour < 16 ? "Good Afternoon" : "Good Evening",
                            style: kTextStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            '$dayOfWeek, $formattedDate',
                            style: kTextStyle.copyWith(color: kGreyTextColor),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            '${_currentTime.hour}:${_currentTime.minute}:${_currentTime.second}',
                            style: kTextStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 25.0,
                            ),
                          ),
                          const SizedBox(height: 30.0),
                          Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100.0),
                              color: isOffice ? kGreenColor.withOpacity(0.1) : kAlertColor.withOpacity(0.1),
                            ),
                            child: GestureDetector(
                               onTap: () {
    if (isOffice) {
      if (isCheckedIn) {
        // Display a Snackbar or another message indicating the user is already checked in
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('You are already checked in. Please check out first.')),
        // );
  toast('You have been checkedIn');

      } else {
        checkIn();
      }
    } else {
      if (isCheckedIn) {
        checkOut();
      } else {
        showCheckInSnackBar();
      }
    }
  },
                              child: CircleAvatar(
                                radius: 80.0,
                                backgroundColor: isOffice ? kGreenColor : kAlertColor,
                                child: Text(
                                  isOffice ? 'Check In' : 'Check Out',
                                  style: kTextStyle.copyWith(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
