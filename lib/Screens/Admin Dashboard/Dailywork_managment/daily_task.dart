import 'package:flutter/material.dart';
import 'package:hrm_employee/Screens/Admin%20Dashboard/Dailywork_managment/daily_task_details.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import DateFormat for date and time formatting

import 'package:provider/provider.dart';
import 'package:hrm_employee/providers/user_provider.dart';
import 'package:hrm_employee/Screens/Outwork%20Submission/task_detail_page.dart';

class DailyTask extends StatefulWidget {
  final String? userId;

  const DailyTask({Key? key, required this.userId}) : super(key: key);

  @override
  _DailyWorkReportState createState() => _DailyWorkReportState();
}

class _DailyWorkReportState extends State<DailyTask>
    with SingleTickerProviderStateMixin {
  late UserData userData;
  late TabController _tabController;
  List<Map<String, dynamic>> taskData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchData();

  }

  Future<void> fetchData() async {
    userData = Provider.of<UserData>(context, listen: false);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.5:3000/task/gettask'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userData.token}',
        },
        body: json.encode({
          'empcode': widget.userId,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> taskRecords = jsonData['taskRecords'];
        List<Map<String, dynamic>> data = taskRecords.map((record) {
          String statusText = '';
          if (record['status'] == false) {
            statusText = 'In Progress';
          } else if (record['status'] == true) {
            statusText = 'Completed';
          } else {
            statusText = 'Unknown';
          }
          return {
            'id': record['ID'] ?? 0,
            'project': record['project'],
            'task_name': record['task_name'],
            'end_date': record['end_date'],
            'descr': record['descr'],
            'status': statusText,
          };
        }).toList();

        // Filter tasks for today's date
        DateTime today = DateTime.now();
        String formattedDate = DateFormat('yyyy-MM-dd').format(today);
        List<Map<String, dynamic>> filteredData = data.where((task) {
          String taskEndDate = task['end_date'].toString().split('T')[0];
          return taskEndDate == formattedDate;
        }).toList();

        setState(() {
          taskData = filteredData;
        });
      } else {
        print('Failed to fetch tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 84, 27, 94),
      appBar: AppBar(
        title: const Text('Daily Task List',
            style: TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          tabs: const [
            Tab(text: 'ALL'),
            Tab(text: 'In Progress'),
            Tab(text: 'Completed'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
        ),
        backgroundColor: const Color.fromARGB(255, 84, 27, 94),
        elevation: 0.0,
        titleSpacing: 0.0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              // topLeft: Radius.circular(30.0),
              // topRight: Radius.circular(30.0),
              ),
          color: Colors.white,
        ),
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTabContent('ALL'),
                  _buildTabContent('In Progress'),
                  _buildTabContent('Completed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String status) {
    List<Map<String, dynamic>> filteredTasks;
    if (status == 'ALL') {
      filteredTasks = taskData;
    } else {
      filteredTasks =
          taskData.where((task) => task['status'] == status).toList();
    }

    filteredTasks = filteredTasks.reversed.toList();

    if (filteredTasks.isEmpty) {
      return const Center(
        child: Text(
          'No tasks available',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }
    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> task = filteredTasks[index];
        return CustomTaskCard(
          id: task['id'],
          taskName: task['task_name'],
          project: task['project'],
          endDate: task['end_date'],
          description: task['descr'],
          status: task['status'],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DailyTaskDetailPage(
                  id: task['id'],
                  taskName: task['task_name'],
                  project: task['project'],
                  endDate: task['end_date'],
                  description: task['descr'],
                  status: task['status'],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class CustomTaskCard extends StatelessWidget {
  final int id;
  final String taskName;
  final String project;
  final String endDate;
  final String description;
  final String status;
  final VoidCallback? onTap;

  const CustomTaskCard({
    Key? key,
    required this.id,
    required this.taskName,
    required this.project,
    required this.endDate,
    required this.description,
    required this.status,
    this.onTap,
  }) : super(key: key);

  Color getBorderColor(String status) {
    switch (status) {
      case 'In Progress':
        return const Color.fromARGB(255, 198, 184, 50);
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Splitting the end date and time
    final dateTime = endDate.split('T');
    final date = dateTime[0];
    final time24 = dateTime.length > 1 ? dateTime[1].split('.')[0] : '';

    // Converting time to 12-hour format with AM/PM
    final time12 = time24.isNotEmpty
        ? DateFormat.jm().format(DateFormat("HH:mm:ss").parse(time24))
        : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 4), // Position of shadow
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: getBorderColor(status),
                width: 8,
              ),
            ),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            title: Text(
              taskName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Project: $project'),
                Text('Date: $date'), // Displaying only date
                if (time12.isNotEmpty)
                  Text(
                      'Time: $time12'), // Displaying only time in 12-hour format
                Text('Status: $status'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

 