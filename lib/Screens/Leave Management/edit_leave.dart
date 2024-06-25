import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hrm_employee/providers/user_provider.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import '../../GlobalComponents/button_global.dart';
import '../../constant.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class EditLeavePage extends StatefulWidget {
  final int id;
  final String leaveType;
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
  late UserData userData; // Assuming UserData class is defined somewhere
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();
  final oneDateController = TextEditingController();
  final descriptionController = TextEditingController();
  final daysController = TextEditingController(); // Number of days
  final remainingLeavesController = TextEditingController(text: '18'); // Remaining leaves

  List<String> numberOfInstallment = ['Plan Leave', 'Casual Leave'];
  String installment = 'Casual Leave'; // Default leave type
  bool isFullDay = true; // Default full day
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;

  @override
   void initState() {
    super.initState();
    descriptionController.text = widget.reason;
    fromDateController.text = widget.fromDate.toString();
    toDateController.text = widget.toDate.toString();
    fromDateController.addListener(updateNumberOfDays);
    toDateController.addListener(updateNumberOfDays);
    // Determine if it's a full-day or half-day leave based on initial data
    if (widget.leaveType == 'Casual') {
      if (widget.halfDayDateRange.isNotEmpty) {
        fromDateController.text =
            DateFormat('yyyy-MM-dd').format(widget.fromDate);
        // Extract start time and end time
        selectedStartTime = TimeOfDay.fromDateTime(
            DateTime.parse(widget.halfDayDateRange.split(' to ')[0]));
        selectedEndTime = TimeOfDay.fromDateTime(
            DateTime.parse(widget.halfDayDateRange.split(' to ')[1]));
        // Check if times are all zeros
        if (selectedStartTime!.hour == 0 &&
            selectedStartTime!.minute == 0 &&
            selectedEndTime!.hour == 0 &&
            selectedEndTime!.minute == 0) {
          isFullDay = true;
        } else {
          isFullDay = false;
        }
      } else {
        isFullDay = true;
        fromDateController.text =
            DateFormat('yyyy-MM-dd').format(widget.fromDate);
      }
    } else {
      installment = 'Plan Leave';
      fromDateController.text =
          DateFormat('yyyy-MM-dd').format(widget.fromDate);
      toDateController.text = DateFormat('yyyy-MM-dd').format(widget.toDate);
    }
    // Calculate initial number of days
    updateNumberOfDays();
  }

  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    descriptionController.dispose();
    daysController.dispose();
    remainingLeavesController.dispose();
    super.dispose();
  }

  void updateNumberOfDays() {
    String fromDate = fromDateController.text;
    String toDate = toDateController.text;

    // Calculate number of days between fromDate and toDate
    DateTime startDate = DateTime.parse(fromDate);
    DateTime endDate = DateTime.parse(toDate);
    int numberOfDays = endDate.difference(startDate).inDays + 1;

    // Update the Number of days field with the calculated value
    daysController.text = numberOfDays.toString();
  }

void editLeave() async {
  String reason = descriptionController.text;
  String days = daysController.text;

  // Determine the half-day value based on isFullDay
  int halfDay = isFullDay ? 0 : 1;

  // Initialize start and end time strings
  String startTime = '';
  String endTime = '';

  if (!isFullDay) {
    startTime = selectedStartTime != null
        ? '${fromDateController.text} ${selectedStartTime!.format(context)}'
        : 'Unknown';
    endTime = selectedEndTime != null
        ? '${fromDateController.text} ${selectedEndTime!.format(context)}'
        : 'Unknown';
  }

  int numberOfDays = days.isNotEmpty ? int.parse(days) : 0;

  int leaveId = installment == 'Casual Leave' ? 1 : 3;

  String fromdate = fromDateController.text;
  String todate = toDateController.text;

  // Adjust fromdate and todate based on conditions
  if (installment == 'Casual Leave') {
    if (isFullDay) {
      todate = fromdate; // If it's full day, todate is same as fromdate
    } else {
      fromdate = startTime; // If it's half day, set fromdate to startTime
      todate = endTime;     // and todate to endTime
    }
  }

  Map<String, dynamic> leaveValues = {
    'id': widget.id,
    'empcode': userData.userID,
    'leaveid': leaveId,
    'leavemode': 1,
    'reason': reason,
    'fromdate': fromdate,
    'todate': todate,
    'half': halfDay,
    'no_of_days': numberOfDays,
    'leave_adjusted': 0,
    'approvel_status': 0,
    'leave_status': 1,
  };

  String jsonData = jsonEncode(leaveValues);

  String url = 'http://192.168.1.7:3000/leave/edit';

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
      print('Leave edited successfully');
      // Show success message
      toast("leave edited successfully");
    } else {
      print('Failed to edit leave: ${response.statusCode}');
      // Show failure message
    }
  } catch (e) {
    print('Exception while editing leave: $e');
    // Show error message
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
          'Edit Apply',
          maxLines: 2,
          style: kTextStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Image(
            image: AssetImage('images/employeesearch.png'),
          ),
        ],
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
                  topRight: Radius.circular(30.0),
                ),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  SizedBox(
                    height: 60.0,
                    child: FormField(
                      builder: (FormFieldState<dynamic> field) {
                        return InputDecorator(
                            decoration: InputDecoration(
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelText: 'Select Leave Type',
                              labelStyle: kTextStyle,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                items: numberOfInstallment.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                value: installment,
                                onChanged: (value) {
                                  setState(() {
                                    installment = value!;
                                  });
                                },
                              ),
                            ));
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  if (installment == 'Casual Leave')
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              activeColor: kMainColor,
                              value: isFullDay,
                              onChanged: (val) {
                                setState(() {
                                  isFullDay = val!;
                                });
                              },
                            ),
                            const SizedBox(width: 4.0),
                            Text('Full Day', style: kTextStyle),
                            Checkbox(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              activeColor: kMainColor,
                              value: !isFullDay,
                              onChanged: (val) {
                                setState(() {
                                  isFullDay = !val!;
                                });
                              },
                            ),
                            const SizedBox(width: 4.0),
                            Text('Half Day', style: kTextStyle),
                          ],
                        ),
                        if (!isFullDay) ...[
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  final TimeOfDay? picked =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (picked != null &&
                                      picked != selectedStartTime) {
                                    setState(() {
                                      selectedStartTime = picked;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color.fromARGB(
                                      255, 85, 125, 244), // Text color
                                  elevation: 4, // Shadow depth
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8), // Rounded corners
                                  ),
                                ),
                                child: Text(selectedStartTime != null
                                    ? selectedStartTime!.format(context)
                                    : 'Select Start Time'),
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: () async {
                                  final TimeOfDay? picked =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (picked != null &&
                                      picked != selectedEndTime) {
                                    setState(() {
                                      selectedEndTime = picked;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color.fromARGB(
                                      255, 85, 125, 244), // Text color
                                  elevation: 4, // Shadow depth
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8), // Rounded corners
                                  ),
                                ),
                                child: Text(selectedEndTime != null
                                    ? selectedEndTime!.format(context)
                                    : 'Select End Time'),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 20.0),
                        AppTextField(
                          textFieldType: TextFieldType.NAME,
                          readOnly: true,
                          onTap: () async {
                            var date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );
                            fromDateController.text =
                                date.toString().substring(0, 10);
                          },
                          controller: fromDateController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            suffixIcon: Icon(
                              Icons.date_range_rounded,
                              color: kGreyTextColor,
                            ),
                            labelText: 'One Date',
                            hintText: '11/09/2021',
                          ),
                        ),
                      ],
                    )
                  else if (installment == 'Plan Leave')
                    Column(
                      children: [
                        AppTextField(
                          textFieldType: TextFieldType.NAME,
                          readOnly: true,
                          onTap: () async {
                            var date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );
                            fromDateController.text =
                                date.toString().substring(0, 10);
                          },
                          controller: fromDateController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            suffixIcon: Icon(
                              Icons.date_range_rounded,
                              color: kGreyTextColor,
                            ),
                            labelText: 'From Date',
                            hintText: '11/09/2021',
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        AppTextField(
                          textFieldType: TextFieldType.NAME,
                          readOnly: true,
                          onTap: () async {
                            var date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );
                            toDateController.text =
                                date.toString().substring(0, 10);
                          },
                          controller: toDateController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            suffixIcon: Icon(
                              Icons.date_range_rounded,
                              color: kGreyTextColor,
                            ),
                            labelText: 'To Date',
                            hintText: '11/09/2021',
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          controller: daysController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Number of days',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: remainingLeavesController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Remaining Leaves',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: descriptionController,
                    maxLines: 5,
                    decoration: kInputDecoration.copyWith(
                      labelText: 'Leave Reason',
                      hintText: 'MaanTheme',
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  ButtonGlobal(
                    buttontext: 'Edit',
                    buttonDecoration:
                        kButtonDecoration.copyWith(color: kMainColor),
                    onPressed: editLeave,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
