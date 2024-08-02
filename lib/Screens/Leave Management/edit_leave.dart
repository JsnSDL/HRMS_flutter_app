import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hrm_employee/Screens/Leave%20Management/leave_management_screen.dart';
import 'package:hrm_employee/providers/user_provider.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import '../../GlobalComponents/button_global.dart';
import '../../constant.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';


class EditLeavePage extends StatefulWidget {
  final int id;
  final String leaveType;
  final String dayType;
  final String halfDayDateRange;
  final String fullDayDateRange;
  final String applyDate;
  final String reason;
  final DateTime fromDate;
  final DateTime toDate;

  const EditLeavePage({
    Key? key,
    required this.id,
    required this.leaveType,
    required this.dayType,
    required this.halfDayDateRange,
    required this.fullDayDateRange,
    required this.applyDate,
    required this.reason,
    required this.toDate,
    required this.fromDate,
  }) : super(key: key);

  @override
  _EditLeavePageState createState() => _EditLeavePageState();
}

class _EditLeavePageState extends State<EditLeavePage> {
  late UserData userData;
  final _formKey = GlobalKey<FormState>();
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();
  final oneDateController = TextEditingController();
  final descriptionController = TextEditingController();
  final daysController = TextEditingController();
  final remainingLeavesController = TextEditingController();
  bool isFullDay = true;
  bool isFirstHalf = true;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  bool _isInitialLoad = true;
  String types = 'Loss Of Pay';
  String daytype = 'FullDay';

  static const Map<int, String> typeOfLeave = {
    1: 'Loss Of Pay',
    2: 'Sick Leave',
    3: 'Earned/Casual Leave',
  };

  static const Map<int, String> typeOfDay = {
    0: 'FullDay',
    1: 'HalfDay',
  };

  String? selectedLeaveType;
  String? selectedTypeOfDay;

  @override
  void initState() {
    super.initState();
    userData = Provider.of<UserData>(context, listen: false);
    descriptionController.text = widget.reason;
    fromDateController.text = widget.fromDate.toIso8601String();
    toDateController.text = widget.toDate.toIso8601String();
    fromDateController.addListener(updateNumberOfDays);
    toDateController.addListener(updateNumberOfDays);
    fromDateController.text = DateFormat('yyyy-MM-dd').format(widget.fromDate);
    toDateController.text = DateFormat('yyyy-MM-dd').format(widget.toDate);
    

    if (widget.leaveType == 'Loss Of Pay' || 
        widget.leaveType == 'Sick Leave' || 
        widget.leaveType == 'Earned/Casual Leave') {
      selectedLeaveType = widget.leaveType;
    }

    if (widget.halfDayDateRange.isNotEmpty) {
      selectedStartTime = TimeOfDay.fromDateTime(
          DateTime.parse(widget.halfDayDateRange.split(' to ')[0]));
      selectedEndTime = TimeOfDay.fromDateTime(
          DateTime.parse(widget.halfDayDateRange.split(' to ')[1]));
      if (selectedStartTime!.hour == 0 &&
          selectedStartTime!.minute == 0 &&
          selectedEndTime!.hour == 0 &&
          selectedEndTime!.minute == 0) {
        isFullDay = true;
        selectedTypeOfDay = 'FullDay';
      } else {
        isFullDay = false;
        selectedTypeOfDay = 'HalfDay';
      }
    } else {
      isFullDay = true;
      selectedTypeOfDay = 'FullDay';
    }

    if(widget.dayType == 'FullDay' || widget.dayType == "HalfDay"){
      selectedTypeOfDay = widget.dayType;
    }

    updateNumberOfDays();
    checkAndUpdateRemainingLeaves();
  }

 @override
 void didChangeDependencies() {
  super.didChangeDependencies();
  if (_isInitialLoad) {
    checkAndUpdateRemainingLeaves();
    _isInitialLoad = false;
  }
}


  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    oneDateController.dispose();
    daysController.dispose();
    remainingLeavesController.dispose();
    fromDateController.removeListener(updateNumberOfDays);
    toDateController.removeListener(updateNumberOfDays);
    super.dispose();
  }


  void updateNumberOfDays() {
  String fromDate = fromDateController.text;
  String toDate = toDateController.text;

  if (fromDate.isNotEmpty) {
    DateTime startDate = DateTime.parse(fromDate);
    DateTime endDate;

    // Check if toDate is provided
    if (toDate.isNotEmpty) {
      endDate = DateTime.parse(toDate);
    } else {
      // Set endDate to startDate if toDate is not provided (assuming it's a half day)
      endDate = startDate;
    }

    int numberOfDays = endDate.difference(startDate).inDays + 1;
    double adjustedNumberOfDays = selectedTypeOfDay == 'HalfDay' ? 0.5 : numberOfDays.toDouble();
    daysController.text = adjustedNumberOfDays.toString();
  }
}


  Future<Map<String, dynamic>> checkLeaveExists(String fromdate, String createddate) async {
    String url = 'http://192.168.1.5:3000/leave/check';

    Map<String, dynamic> requestBody = {
      'company_id': '2',
      'empcode': userData.userID,
      'fromdate': fromdate,
      'createddate': createddate,
    };

    String jsonData = jsonEncode(requestBody);

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
        var responseBody = jsonDecode(response.body);
        return {
          'exists': responseBody['exists'],
          'no_of_days': responseBody['no_of_days']
        };
      } else {
        print('Failed to check leave: ${response.statusCode}');
        return {
          'exists': false,
          'no_of_days': null
        };
      }
    } catch (e) {
      print('Exception while checking leave: $e');
      return {
        'exists': false,
        'no_of_days': null
      };
    }
  }

  void checkAndUpdateRemainingLeaves() async {
    String url = 'http://192.168.1.5:3000/leave/remain';

    Map<String, dynamic> requestBody = {
      'company_id': '2',
      'empcode': userData.userID,
    };

    String jsonData = jsonEncode(requestBody);

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
        var responseBody = jsonDecode(response.body);

        double remainingSickLeaves = (responseBody['leaveData']['2']['total'] as num).toDouble() - (responseBody['leaveData']['2']['used'] as num).toDouble();
        double remainingEarnedLeaves = (responseBody['leaveData']['3']['total'] as num).toDouble() - (responseBody['leaveData']['3']['used'] as num).toDouble();
        bool isEligibleForOtherLeaves = responseBody['isEligibleForOtherLeaves'];

        setState(() {
          if (isEligibleForOtherLeaves) {
            remainingLeavesController.text = (remainingSickLeaves + remainingEarnedLeaves).toStringAsFixed(1);
          } else {
            remainingLeavesController.text = '0'; // Not eligible for Sick/Earned/Casual Leave
          }
        });
      } else {
        print('Failed to check leave: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception while checking leave: $e');
    }
  }

 void editLeave() async {
  String fromDate = fromDateController.text;
  String toDate = toDateController.text;
  String oneDate = oneDateController.text;
  String reason = descriptionController.text;

  int halfDay = selectedTypeOfDay == 'FullDay' ? 0 : 1;

  String startTime = '';
  String endTime = '';

  if (selectedTypeOfDay == 'HalfDay') {
    startTime = selectedStartTime != null ? '$fromDate ${selectedStartTime!.format(context)}' : 'Unknown';
    endTime = selectedEndTime != null ? '$fromDate ${selectedEndTime!.format(context)}' : 'Unknown';
  }

  // Calculate numberOfDays based on leave type
  double numberOfDays;
  if (selectedTypeOfDay == 'FullDay') {
    if (fromDate.isNotEmpty && toDate.isNotEmpty) {
      DateTime startDate = DateTime.parse(fromDate);
      DateTime endDate = DateTime.parse(toDate);
      numberOfDays = endDate.difference(startDate).inDays + 1;
    } else {
      numberOfDays = 1.0; // Default to 1 day if 'fromDate' and 'toDate' are empty
    }
  } else {
    numberOfDays = 0.5;
  }

  // Determine leaveId based on selectedLeaveType
  int leaveId;
  switch (selectedLeaveType) {
    case 'Sick Leave':
      leaveId = 2;
      break;
    case 'Earned/Casual Leave':
      leaveId = 3;
      break;
    case 'Loss of Pay':
      leaveId = 1; // Assign leaveId 1 for Loss of Pay
      break;
    default:
      leaveId = 1; // Default leaveId
  }

  String createdDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());

  // Check if leave already exists or if leaves are exhausted
  Map<String, dynamic> leaveExists = await checkLeaveExists(fromDate, createdDate);

  // Adjust remaining leaves based on leave type and availability
  double remainingLeaves;
  try {
    remainingLeaves = double.parse(remainingLeavesController.text);
  } catch (e) {
    toast('Invalid remaining leaves value.');
    return;
  }

  if (leaveId != 1 && remainingLeaves >= numberOfDays) {
    remainingLeaves -= numberOfDays;
  } else if (leaveId == 1) {
    // Handle Loss of Pay scenario where remainingLeaves are not adjusted
    // You may handle specific logic for Loss of Pay here
  } else {
    toast('You do not have enough remaining leaves');
    return;
  }

  remainingLeavesController.text = remainingLeaves.toStringAsFixed(1);


  // Prepare the JSON data to send to the server
  Map<String, dynamic> data = {
    'id': widget.id,
    'empcode': userData.userID,
    'leaveid': leaveId,
    'leavemode': 1,
    'reason': reason,
    'fromdate':  selectedTypeOfDay == 'FullDay' ? fromDate : startTime,
    'todate': selectedTypeOfDay == 'FullDay' ? toDate : endTime,  
    'half': halfDay,
    'no_of_days': numberOfDays,
  };

  String jsonData = jsonEncode(data);

  String url = 'http://192.168.1.5:3000/leave/edit';

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
      toast('Leave updated successfully');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LeaveManagementScreen(),
        ),
      );
    } else {
      final errorResponse = jsonDecode(response.body);
      toast(errorResponse['message']);
    }
  } catch (e) {
    toast('Exception while updating leave: $e');
  }
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Edit Leave Apply',
          maxLines: 2,
          style: kTextStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
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
                    topRight: Radius.circular(30.0),
                  ),
                  color: Colors.white,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20.0),
                      // Dropdown for selecting Leave Type
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text('Leave Type',
                          style: kTextStyle.copyWith(fontWeight: FontWeight.bold),
                           ),
                          const SizedBox(height: 20.0),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color.fromRGBO(192, 190, 190, 1)),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10.0))),
                            child: CustomDropdown(
                              items: typeOfLeave.values.toList(),
                              hintText: 'Select Leave types',
                              initialItem: types,
                              onChanged: (newValue) {
                                setState(() {
                                  types = selectedLeaveType = newValue.toString();
                                  // Reset time selections when changing leave type
                                  selectedStartTime = null;
                                  selectedEndTime = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      // Dropdown for selecting Type of Day (FullDay or HalfDay)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text('Leave Mode',
                          style: kTextStyle.copyWith(fontWeight: FontWeight.bold),
                           ),
                          const SizedBox(height: 20.0),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color.fromRGBO(192, 190, 190, 1)),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10.0))),
                            child: CustomDropdown(
                              items: typeOfDay.values.toList(),
                              hintText: 'Select Type of Day',
                              initialItem: daytype,
                              onChanged: (newValue) {
                                setState(() {
                                  daytype = selectedTypeOfDay = newValue.toString();
                                  // Reset time selections when changing type of day
                                  selectedStartTime = null;
                                  selectedEndTime = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                    
                      // Remaining Leaves (calculated automatically)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text('Leave Balance',
                          style: kTextStyle.copyWith(fontWeight: FontWeight.bold),
                           ),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            readOnly: true,
                            controller: remainingLeavesController,
                            decoration: const InputDecoration(
                              hintText: 'Remaining Leaves',
                              contentPadding:  EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20.0))
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      // Date Range Selection (From Date and To Date)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'From Date',
                                  style: kTextStyle.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  readOnly: true,
                                  controller: fromDateController,
                                  decoration: const InputDecoration(
                                    hintText: 'Select Date',
                                    contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(20.0))
                                    ),
                                  ),
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(DateTime.now().year + 1),
                                      builder: (BuildContext context, Widget? child) {
                                        return Theme(
                                          data: ThemeData.light().copyWith(
                                            primaryColor: kMainColor,
                                            // accentColor: kMainColor,
                                            colorScheme: const ColorScheme.light(primary: kMainColor),
                                            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (pickedDate != null) {
                                      fromDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                                      updateNumberOfDays();
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a start date';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20.0),
                          if (selectedTypeOfDay != 'HalfDay') // Only show To Date picker if Full Day is selected
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'To Date',
                                    style: kTextStyle.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8.0),
                                  TextFormField(
                                    readOnly: true,
                                    controller: toDateController,
                                    decoration: const InputDecoration(
                                      hintText: 'Select Date',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                      ),
                                    ),
                                    onTap: () async {
                                      DateTime? pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(DateTime.now().year + 1),
                                        builder: (BuildContext context, Widget? child) {
                                          return Theme(
                                            data: ThemeData.light().copyWith(
                                              primaryColor: kMainColor,
                                              // accentColor: kMainColor,
                                              colorScheme: const ColorScheme.light(primary: kMainColor),
                                              buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (pickedDate != null) {
                                        toDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                                        updateNumberOfDays();
                                      }
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select an end date';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      // Time Pickers (only shown for HalfDay)
                      if (selectedTypeOfDay == 'HalfDay') ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start Time',
                                    style: kTextStyle.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8.0),
                                  GestureDetector(
                                    onTap: () async {
                                      TimeOfDay? pickedTime = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );
                                      if (pickedTime != null) {
                                        setState(() {
                                          selectedStartTime = pickedTime;
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            selectedStartTime != null
                                                ? selectedStartTime!.format(context)
                                                : 'Select Time',
                                            style: TextStyle(
                                              color: selectedStartTime != null ? Colors.black : Colors.grey,
                                            ),
                                          ),
                                          const Icon(Icons.access_time, color: kMainColor),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (selectedStartTime == null)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        'Please select a start time',
                                        style: TextStyle(color: Colors.red, fontSize: 12),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'End Time',
                                    style: kTextStyle.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8.0),
                                  GestureDetector(
                                    onTap: () async {
                                      TimeOfDay? pickedTime = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );
                                      if (pickedTime != null) {
                                        setState(() {
                                          selectedEndTime = pickedTime;
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            selectedEndTime != null ? selectedEndTime!.format(context) : 'Select Time',
                                            style: TextStyle(
                                              color: selectedEndTime != null ? Colors.black : Colors.grey,
                                            ),
                                          ),
                                          const Icon(Icons.access_time, color: kMainColor),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (selectedEndTime == null)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        'Please select an end time',
                                        style: TextStyle(color: Colors.red, fontSize: 12),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20.0),
                         // Number of Days (calculated automatically based on From Date and To Date)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text('Number of Days',
                          style: kTextStyle.copyWith(fontWeight: FontWeight.bold),
                           ),
                          const SizedBox(height: 20.0),
                          TextFormField(
                            readOnly: true,
                            controller: daysController,
                            decoration: const InputDecoration(
                              hintText: 'Number of Days',
                              contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20.0))
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      // Reason for Leave
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text('Reason',
                          style: kTextStyle.copyWith(fontWeight: FontWeight.bold),
                           ),
                          const SizedBox(height:20.0),
                          TextFormField(
                            controller: descriptionController,
                            keyboardType: TextInputType.multiline,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'Reason for Leave',
                              contentPadding: EdgeInsets.all(15.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20.0))
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a reason for leave';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                     
                      // Apply Button
                      ButtonGlobal(
                        buttontext: 'Apply',
                        buttonDecoration: kButtonDecoration.copyWith(
                          color: kMainColor,
                          borderRadius: const BorderRadius.all(Radius.circular(20.0))
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Perform the apply leave action if form is valid
                            editLeave();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
