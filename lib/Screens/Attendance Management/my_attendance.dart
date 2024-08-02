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
    userData = Provider.of<UserData>(context, listen: false);
    _loadIntime();
    _fetchLocation();
  }

  void _loadIntime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedIntime = prefs.getString('${userData.userID}_intime');
    setState(() {
      intime = savedIntime ?? '';
      isCheckedIn = intime.isNotEmpty && _isSameDay(intime);
      if (!isCheckedIn) {
        _clearIntime();
      }
    });
  }

 bool _isSameDay(String intime) {
    DateTime checkInDate = DateTime.parse(intime);
    DateTime now = DateTime.now();
    return checkInDate.year == now.year && checkInDate.month == now.month && checkInDate.day == now.day;
  }

   void _saveIntime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentTime =  DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    prefs.setString('${userData.userID}_intime', currentTime);
    setState(() {
      intime = currentTime;
      isCheckedIn = true;
    });
  }

  void _clearIntime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('${userData.userID}_intime');
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

  Future<void> _fetchLocation() async {
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
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final response = await http.post(
        Uri.parse('http://192.168.1.5:3000/attendance/get'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userData.token}',
        },
        body: json.encode({
          'empcode': userData.userID,
          'startDate': formattedDate,
          'endDate': formattedDate,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> attendanceRecords = jsonData['attendanceRecords'];
        return List<Map<String, dynamic>>.from(attendanceRecords);
      } else {
        print('Failed to load attendance records: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      print('Error fetching attendance records: $error');
      return [];
    }
  }

 void checkIn() async {

  List<Map<String, dynamic>> attendance = await fetchAttendanceData();
  

  bool hasOuttime = attendance.isNotEmpty && attendance.any((record) {
    return record['outtime'] != null && record['outtime'].isNotEmpty;
  });

  if (hasOuttime) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You have already completed your attendance for today.'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }
    if (isCheckedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already clocked in for today.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    _saveIntime();
     intime =  DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    
    Map<String, dynamic> attendanceData = {
      'companyID': '10',
      'empcode': userData.userID,
      'exactdate': formattedDate,
      'intime': intime,
      'location': locationName,
    };

    String jsonData = jsonEncode(attendanceData);

    String url = 'http://192.168.1.5:3000/attendance/time';

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
        print('Check-in time posted successfully');
        toast("You have been clocked in");
      } else {
        print('Failed to post check-in time: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception while posting check-in time: $e');
    }

    setState(() {
      isCheckedIn = true;
    });
  }

  void checkOut() async {
    if (!isCheckedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please clock in first.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    String outime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    Map<String, dynamic> attendanceData = {
      'companyID': '10',
      'empcode': userData.userID,
      'exactdate': formattedDate,
      'outtime': outime,
    };

    String jsonData = jsonEncode(attendanceData);

    String url = 'http://192.168.1.5:3000/attendance/update';

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have been clocked out.'),
            duration: Duration(seconds: 2),
          ),
        );
        _clearIntime();
      } else {
        print('Failed to post out time: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception while posting out time: $e');
    }

    setState(() {
      isCheckedIn = false;
    });
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
    if (!userData.isTokenLoaded) {
    _clearIntime();
  }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kMainColor,
      appBar: AppBar(
        backgroundColor: kMainColor,
        elevation: 0.0,
        titleSpacing: 0.0,
        iconTheme: const IconThemeData(color: Colors.white),
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
                  const SizedBox(height: 10.0),
                      if (isCheckedIn)
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Status: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    fontSize: 20.0),
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                'You have been clocked in for today',
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                  Container(
                    width: context.width(),
                    padding: const EdgeInsets.all(14.0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                    
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
                                        'In Time',
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
                                        'Out Time',
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
                            _currentTime.hour < 12
                                ? "Good Morning"
                                : _currentTime.hour < 16
                                    ? "Good Afternoon"
                                    : "Good Evening",
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('You are already clocked in. Please clock out first.'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
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
                                  isOffice ? 'Clock In' : 'Clock Out',
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