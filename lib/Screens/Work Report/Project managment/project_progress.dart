import 'package:flutter/material.dart';
import 'package:hrm_employee/Screens/Work%20Report/Project%20managment/project_details.dart';
import 'package:hrm_employee/constant.dart';
import 'package:hrm_employee/providers/user_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Project {
  final String name;
  final int completed;
  final int pending;
  final String description;
  final String taskAssigner;
  final String teamLead;
  final List<String> teamMembers; // List of team members
  final DateTime deadline;

  Project({
    required this.name,
    required this.completed,
    required this.pending,
    required this.description,
    required this.taskAssigner,
    required this.teamLead,
    required this.teamMembers,
    required this.deadline,
  });
}

class ProjectProgress extends StatefulWidget {
  @override
  _ProjectProgressState createState() => _ProjectProgressState();
}

class _ProjectProgressState extends State<ProjectProgress> {
  late UserData userData;
  List<Project> projects = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final userData = Provider.of<UserData>(context, listen: false);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.5:3000/task/fetchProjectEmployee'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userData.token}',
        },
        body: json.encode({'empcode': userData.userID}),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> projectRecords = jsonData['projectRecords'];

        List<Project> fetchedProjects = projectRecords.map((record) {
          return Project(
            name: record['project'],
            completed: record['completed'] ?? 40,
            pending: record['pending'] ?? 60,
            description: record['description'],
            taskAssigner: '', // Modify as needed based on your data structure
            teamLead: record['teamLead'],
            teamMembers: List<String>.from(record['teamMembers'] ?? []),
            deadline: DateTime.parse(record['deadline']),
          );
        }).toList();

        setState(() {
          projects = fetchedProjects;
        });
      } else {
        print('Failed to fetch projects: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching projects: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      appBar: AppBar(
        title: const Text(
          'Project Progress',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: kMainColor,
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50.0),
            topRight: Radius.circular(50.0),
          ),
          color: Colors.white,
        ),
        child: projects.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  return _buildProjectContainer(context, projects[index]);
                },
              ),
      ),
    );
  }

  Widget _buildProjectContainer(BuildContext context, Project project) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailsPage(project: project),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.name,
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0),
            _buildProgressBar(project.completed, project.pending),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Completed: ${project.completed}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Pending: ${project.pending}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Deadline: ${project.deadline.day}/${project.deadline.month}/${project.deadline.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectDetailsPage(project: project),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12.0),
             Text(
              'Team Lead: ${project.teamLead}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            Text(
              'Team Members (${project.teamMembers.length}):',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  project.teamMembers.map((member) => Text(member)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int completed, int pending) {
    int total = completed + pending;
    double completedPercent = (completed / total);
    double pendingPercent = (pending / total);

    return Row(
      children: [
        Expanded(
          flex: completed,
          child: Container(
            height: 10.0,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 143, 248, 147),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5.0),
                bottomLeft: Radius.circular(5.0),
              ),
            ),
          ),
        ),
        Expanded(
          flex: pending,
          child: Container(
            height: 10.0,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 255, 117, 108),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(5.0),
                bottomRight: Radius.circular(5.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
