import 'package:flutter/material.dart';
import 'package:hrm_employee/Screens/Admin%20Dashboard/Project%20managment/project_progress.dart';

class OverviewTab extends StatelessWidget {
  final Project project;

  OverviewTab({required this.project});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Project Name',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Text(
              project.name,
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 12.0),
            _buildProgressIndicator(project.completed, Colors.green),
            const SizedBox(height: 8.0),
            const Text(
              'Description',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              project.description,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14.0,
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.assignment_ind, color: Colors.blue),
              title: const Text(
                'Team Lead',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              subtitle: Text(
                project.teamLead,
                style: TextStyle(color: Colors.grey[800]),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.blue),
              title: const Text(
                'Team',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              subtitle: _buildTeamMembers(project.teamMembers),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Deadline',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  '${project.deadline.day}/${project.deadline.month}/${project.deadline.year}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4.0),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: 4.0),
        Text(
          '$value%',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamMembers(List<String> members) {
    if (members.isEmpty) {
      return const Text(
        'No team members assigned',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 14.0,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: members
          .map(
            (member) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  const SizedBox(width: 8.0),
                  Text(
                    member,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
