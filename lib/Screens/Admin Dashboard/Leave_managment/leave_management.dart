import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hrm_employee/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class LeaveManagementPage extends StatefulWidget {
  const LeaveManagementPage({Key? key}) : super(key: key);

  @override
  _LeaveManagementPageState createState() => _LeaveManagementPageState();
}

class _LeaveManagementPageState extends State<LeaveManagementPage> {
  late UserData userData;
  List<LeaveData> leaveData = [];

  @override
  void initState() {
    super.initState();
    userData = Provider.of<UserData>(context, listen: false);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (userData.isTokenLoaded) {
        fetchLeaveData();
      } else {
        userData.addListener(() {
          if (userData.isTokenLoaded) {
            fetchLeaveData();
          }
        });
      }
    });
  }

  Future<void> fetchLeaveData() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.4:3000/leave/approveGet'),
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
        final List<dynamic> leaveRecords = jsonData['leaveRecords'];
        setState(() {
          leaveData = leaveRecords.map((record) {
            String leaveType;
            if (record['leaveType'] == 1) {
              leaveType = 'Casual';
            } else if (record['leaveType'] == 3) {
              leaveType = 'Plan';
            } else {
              leaveType = 'Unknown';
            }

            final fromDate = record['fromdate'] != null
                ? DateFormat('yyyy-MM-dd HH:mm')
                    .format(DateTime.parse(record['fromdate']))
                : 'Unknown';
            final toDate = record['todate'] != null
                ? DateFormat('yyyy-MM-dd HH:mm')
                    .format(DateTime.parse(record['todate']))
                : 'Unknown';
            final applyDate = record['createddate'] != null
                ? DateFormat('yyyy-MM-dd HH:mm')
                    .format(DateTime.parse(record['createddate']))
                : 'Unknown';
            final status = record['approvel_status'] ?? 'Unknown';

            return LeaveData(
              id: record['id'],
              leaveType: leaveType,
              dateRange: '$fromDate to $toDate',
              applyDate: applyDate,
              status: status,
              empcode: record['empcode'],
            );
          }).toList();
        });
      } else {
        throw Exception('Failed to load leave records');
      }
    } catch (error) {
      print('Error fetching leave records: $error');
    }
  }

  Future<void> updateLeaveStatus(
    int id, String empcode, bool approve) async {
    try {
      // Show confirmation dialog
      await showConfirmationDialog(context, id, empcode, approve);
    } catch (error) {
      print('Error showing confirmation dialog: $error');
    }
  }

  Future<void> showConfirmationDialog(
      BuildContext context, int id, String empcode, bool approve) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Action'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Are you sure you want to ${approve ? 'approve' : 'reject'} this leave application?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                performLeaveUpdate(id, empcode,
                    approve); // Proceed with approval/rejection
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> performLeaveUpdate(
      int id, String empcode, bool approve) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.4:3000/leave/approve'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userData.token}',
        },
        body: json.encode({
          'id': id,
          'approve': approve ? 1 : 0,
          'empcode': empcode,
        }),
      );

      if (response.statusCode == 200) {
        print('Leave status updated successfully');
        fetchLeaveData(); // Refresh leave data to reflect changes
        showApprovalDialog(context, approve); // Show approval/rejection dialog
      } else {
        print('Failed to update leave status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to update leave status');
      }
    } catch (error) {
      print('Error updating leave status: $error');
    }
  }

  void showApprovalDialog(BuildContext context, bool approved) {
    String action = approved ? 'Approved' : 'Rejected';
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$action Successfully'),
          content: Text('Leave Application ${action.toLowerCase()}!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 84, 27, 94),
      appBar: AppBar(
        title: const Text(
          'Leave Management',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 84, 27, 94),
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20.0),
            Expanded(
              child: Container(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Leave Applications',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        child: leaveData.isEmpty
                            ? Container(
                        margin:const EdgeInsets.symmetric(vertical: 250.0),
                              child: const Center(
                                  child: Text(
                                    'No leaves to be approved',
                                    style:
                                        TextStyle(fontSize: 18, color: Colors.black54),
                                  ),
                                ),
                            )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: leaveData.length,
                                itemBuilder: (context, index) {
                                  return LeaveApplicationCard(
                                    leaveApplication: leaveData[index],
                                    onUpdateLeaveStatus: updateLeaveStatus,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}

class LeaveData {
   final int id;
  final String leaveType;
  final String dateRange;
  final String applyDate;
  final String status;
  final String empcode;

  LeaveData({
    required this.id,
    required this.leaveType,
    required this.dateRange,
    required this.applyDate,
    required this.status,
    required this.empcode,
  });
}

class LeaveApplicationCard extends StatelessWidget {
  final LeaveData leaveApplication;
  final Function(int, String, bool) onUpdateLeaveStatus;

  const LeaveApplicationCard({
    Key? key,
    required this.leaveApplication,
    required this.onUpdateLeaveStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leave Type: ${leaveApplication.leaveType}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Date Range: ${leaveApplication.dateRange}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Applied On: ${leaveApplication.applyDate}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${leaveApplication.status}',
              style: TextStyle(
                fontSize: 16,
                color: leaveApplication.status == 'Pending'
                    ? Colors.orange
                    : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Employee Code: ${leaveApplication.empcode}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    onUpdateLeaveStatus(leaveApplication.id,
                        leaveApplication.empcode, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 66, 179, 70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Approve',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    onUpdateLeaveStatus(leaveApplication.id,
                        leaveApplication.empcode, false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 249, 90, 79),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Reject',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
