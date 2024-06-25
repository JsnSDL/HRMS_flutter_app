import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hrm_employee/services/location_util.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
// ignore: unused_import
import 'package:hrm_employee/constant.dart';
import 'package:hrm_employee/services/database_helper.dart';

class AttendanceProvider extends ChangeNotifier {
  late final DatabaseHelper _databaseHelper;
  bool isCheckedIn = false;
  bool isCheckInButtonEnabled = true;
  String locationName = '';

  AttendanceProvider() {
    _databaseHelper = DatabaseHelper();
    _updateTime();
    _startTimer();
  }

  bool isOffice = true;
  // ignore: unused_field
  late Timer _timer;
  late DateTime _currentTime;

  DateTime get currentTime => _currentTime;
  String get formattedDate => DateFormat('dd-MMM-yyyy').format(_currentTime);
  String get dayOfWeek => DateFormat('EEEE').format(_currentTime);
  String get greetingMessage {
    if (_currentTime.hour < 12) {
      return "Good Morning";
    } else if (_currentTime.hour < 16) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    _currentTime = DateTime.now();
    notifyListeners();
  }

  void checkIn(BuildContext context) async {
    if (!isCheckInButtonEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already checked in for today.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Get current location
    Map<String, double?>? location = await LocationUtil.getLocation(context);

    if (location == null ||
        location['latitude'] == null ||
        location['longitude'] == null) {
          //ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to retrieve location. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    double? latitude = location['latitude'];
    double? longitude = location['longitude'];

    List<Map<String, dynamic>> todayAttendance =
        await _databaseHelper.getAttendanceByDate(formattedDate);

    if (todayAttendance.isNotEmpty && todayAttendance.first['isCheckIn'] == 1) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already checked in for today.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Map<String, dynamic> attendanceData = {
      'date': formattedDate,
      'time':
          '${_currentTime.hour}:${_currentTime.minute}:${_currentTime.second}',
      'isCheckIn': 1,
      'latitude': latitude, // Store latitude
      'longitude': longitude, // Store longitude
    };

    await _databaseHelper.insertAttendance(attendanceData);

    isCheckedIn = true;
    isCheckInButtonEnabled = false; // Disable the button after check-in
    notifyListeners();
  }

  void checkOut(BuildContext context) async {
    // Check if the user has checked in before allowing checkout
    if (!isCheckedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check in first.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Get current location
    Map<String, double?>? location = await LocationUtil.getLocation(context);

    if (location == null ||
        location['latitude'] == null ||
        location['longitude'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to retrieve location. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    double? latitude = location['latitude'];
    double? longitude = location['longitude'];

    Map<String, dynamic> attendanceData = {
      'date': formattedDate,
      'time':
          '${_currentTime.hour}:${_currentTime.minute}:${_currentTime.second}',
      'isCheckIn': 0,
      'latitude': latitude,
      'longitude': longitude, 
    };

    await _databaseHelper.insertAttendance(attendanceData);

    isCheckedIn = false;
    notifyListeners();
  }

  void viewAttendance(BuildContext context) async {
    List<Map<String, dynamic>> todayAttendance =
        await _databaseHelper.getAttendanceByDate(formattedDate);

    // ignore: use_build_context_synchronously
    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Today\'s Attendance',
            style: TextStyle(
              color: Colors.blue, // Example color
              fontSize: 20, // Example font size
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date: $formattedDate',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16, // Example font size
                ),
              ),
              const SizedBox(height: 10),
              if (todayAttendance.isEmpty)
                const Text(
                  'No attendance recorded for today.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey, // Example color
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: todayAttendance.map((record) {
                    String time = record['time'];
                    bool isCheckIn = record['isCheckIn'] == 1;
                    String mode = isCheckIn ? 'Checked In' : 'Checked Out';
                    String locationInfo =
                        'Latitude: ${record['latitude']}, Longitude: ${record['longitude']}';

                    return FutureBuilder<void>(
                      future: getLocationName(record),
                      builder:
                          (BuildContext context, AsyncSnapshot<void> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Text(
                                '$mode - $time',
                                style: const TextStyle(
                                  fontSize: 16, // Example font size
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                locationInfo,
                                style: const TextStyle(
                                  fontSize: 14, // Example font size
                                  // fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              // const SizedBox(
                              //   height: 5,
                              // ),
                              // Text(
                              //   'Location Name: $locationName',
                              //   style: const TextStyle(
                              //     fontSize: 14, // Example font size
                              //     color: Colors.grey, // Example color
                              //   ),
                              // ),
                              // const SizedBox(height: 10),
                            ],
                          );
                        }
                      },
                    );
                  }).toList(),
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.red, // Example color
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void viewLocation(BuildContext context) async {
    List<Map<String, dynamic>> todayAttendance =
        await _databaseHelper.getAttendanceByDate(formattedDate);

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Today\'s Attendance',
            style: TextStyle(
              color: Colors.blue, // Example color
              fontSize: 20, // Example font size
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date: $formattedDate',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16, // Example font size
                ),
              ),
              const SizedBox(height: 10),
              if (todayAttendance.isEmpty)
                const Text(
                  'No attendance recorded for today.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey, // Example color
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: todayAttendance.map((record) {
                    String time = record['time'];
                    bool isCheckIn = record['isCheckIn'] == 1;
                    String mode = isCheckIn ? 'Checked In' : 'Checked Out';
                    // ignore: unused_local_variable
                    String locationInfo =
                        'Latitude: ${record['latitude']}, Longitude: ${record['longitude']}';

                    return FutureBuilder<void>(
                      future: getLocationName(record),
                      builder:
                          (BuildContext context, AsyncSnapshot<void> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Text(
                                '$mode - $time',
                                style: const TextStyle(
                                  fontSize: 16, // Example font size
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Location Name: $locationName',
                                style: const TextStyle(
                                  fontSize: 14, // Example font size
                                  color: Colors.grey, // Example color
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    );
                  }).toList(),
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.red, // Example color
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> getLocationName(Map<String, dynamic> record) async {
    final latitude = record['latitude'];
    final longitude = record['longitude'];

    final url =
        'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json';

    try {
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        final data = response.data;
        locationName = data['display_name'];
        notifyListeners();
      } else {
        throw Exception(
            'Failed to fetch location data from OpenStreetMap Nominatim API');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  void showCheckInSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please check in first.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void setAttendanceMode(bool mode) {
    isOffice = mode;
    notifyListeners();
  }
}
