// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class AttendanceManagementPage extends StatefulWidget {
  const AttendanceManagementPage({Key? key}) : super(key: key);

  @override
  _AttendanceManagementPageState createState() =>
      _AttendanceManagementPageState();
}

class _AttendanceManagementPageState extends State<AttendanceManagementPage> {
  Map<String, String> employeeAttendance = {
    'Rakesh Swain': 'Present',
    'Jason Desuza': 'Absent',
    'Malikarjun Khadge': 'Present',
    'Anup Meheta': 'Present',
    'Prasana Babu': 'Absent',
    'Kumar CD': 'Present',
    'Simran VishwKrama': 'Present',
    'Summanth': 'Present',
    'Umesh': 'Absent',
    'Kalin Bhaiya': 'Present',
  };

  late TextEditingController _searchController;
  List<MapEntry<String, String>> filteredEmployeeAttendance = [];

  bool _isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _updateFilteredAttendance('');
  }

  void _onSearchChanged() {
    _updateFilteredAttendance(_searchController.text);
  }

  void _updateFilteredAttendance(String query) {
    setState(() {
      filteredEmployeeAttendance = employeeAttendance.entries
          .where(
              (entry) => entry.key.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 84, 27, 94),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: _isSearchOpen
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
              )
            : const Text(
                'Attendance Management',
                style: TextStyle(color: Colors.white),
              ),
        backgroundColor: const Color.fromARGB(255, 84, 27, 94),
        elevation: 0.0,
        actions: _buildAppBarActions(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20.0,
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Employee Attendance',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredEmployeeAttendance.length,
                    itemBuilder: (context, index) {
                      final entry = filteredEmployeeAttendance[index];
                      return AttendanceCard(
                        name: entry.key,
                        status: entry.value,
                        onChanged: (newValue) {
                          setState(() {
                            employeeAttendance[entry.key] = newValue;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearchOpen) {
      return [
        IconButton(
          icon: const Icon(
            Icons.close,
          ),
          onPressed: () {
            setState(() {
              _isSearchOpen = false;
              _searchController.clear();
              _updateFilteredAttendance('');
            });
          },
        ),
      ];
    } else {
      return [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearchOpen = true;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.file_download),
          onPressed: () {
            _generateAttendanceReport();
          },
        ),
      ];
    }
  }

  void _generateAttendanceReport() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Attendance Report'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var entry in employeeAttendance.entries)
                  ListTile(
                    title: Text(entry.key),
                    subtitle: Text(entry.value),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class AttendanceCard extends StatefulWidget {
  final String name;
  final String status;
  final ValueChanged<String>? onChanged;

  const AttendanceCard({
    Key? key,
    required this.name,
    required this.status,
    this.onChanged,
  }) : super(key: key);

  @override
  _AttendanceCardState createState() => _AttendanceCardState();
}

class _AttendanceCardState extends State<AttendanceCard> {
  late String dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.status;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 20),
            DropdownButton<String>(
              value: dropdownValue,
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                  widget.onChanged?.call(newValue);
                });
              },
              items: const <String>[
                'Present',
                'Absent',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
