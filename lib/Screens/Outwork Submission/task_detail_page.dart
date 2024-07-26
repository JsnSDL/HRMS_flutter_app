import 'package:flutter/material.dart';
import 'package:hrm_employee/Screens/Outwork%20Submission/edit_task.dart';
import 'package:hrm_employee/constant.dart';
import 'package:intl/intl.dart'; // Import the intl package

class TaskDetailPage extends StatefulWidget {
  final int id;
  final String taskName;
  final String project;
  final String dept;
  final String endDate;
  final String description;
  final String status;

  TaskDetailPage({
    required this.id,
    required this.taskName,
    required this.project,
    required this.dept,
    required this.endDate,
    required this.description,
    required this.status,
  });

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  @override
  Widget build(BuildContext context) {
    // Splitting the end date and time
    final dateTime = widget.endDate.split('T');
    final date = dateTime[0];
    final time24 = dateTime.length > 1 ? dateTime[1].split('.')[0] : '';

    // Converting time to 12-hour format with AM/PM
    final time12 = time24.isNotEmpty
        ? DateFormat.jm().format(DateFormat("HH:mm:ss").parse(time24))
        : '';

    return Scaffold(
      backgroundColor: kMainColor,
      appBar: AppBar(
        backgroundColor: kMainColor,
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.taskName,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskEditPage(
                    id: widget.id,
                    taskName: widget.taskName,
                    project: widget.project,
                    dept: widget.dept,
                    endDate: widget.endDate,
                    description: widget.description,
                    status: widget.status,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailColumn('Project', widget.project),
                      _buildDetailColumn('Department', widget.dept),
                      _buildDetailColumn('End Date', date),
                      _buildDetailColumn('End Time', time12),
                      _buildDetailColumn('Description', widget.description),
                      _buildDetailColumn('Status', widget.status),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
