import 'package:flutter/material.dart';
import 'package:hrm_employee/Screens/Work%20Report/Project%20managment/calendar_tab.dart';
import 'package:hrm_employee/Screens/Work%20Report/Project%20managment/overview_tab.dart';
import 'package:hrm_employee/Screens/Work%20Report/Project%20managment/project_progress.dart';
import 'package:hrm_employee/Screens/Work%20Report/Project%20managment/task_tab.dart';
import 'package:hrm_employee/constant.dart';

class ProjectDetailsPage extends StatefulWidget {
  final Project project;

  ProjectDetailsPage({required this.project});

  @override
  _ProjectDetailsPageState createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Project Details - ${widget.project.name}',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: kMainColor,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: const Color.fromARGB(255, 172, 170, 170),
          labelStyle: const TextStyle(fontSize: 17.0),
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Tasks'),
            Tab(text: 'Calendar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          OverviewTab(project: widget.project),
          TasksTab(project: widget.project),
          CalendarTab(),
        ],
      ),
    );
  }
}
