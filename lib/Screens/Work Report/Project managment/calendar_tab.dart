import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Reminder {
  final TimeOfDay time;
  final String description;

  Reminder(this.time, this.description);
}

class CalendarTab extends StatefulWidget {
  @override
  _CalendarTabState createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  // Sample event data with reminders
  Map<DateTime, List<Map<String, dynamic>>> _events = {
    DateTime(2024, 7, 25): [
      {
        'name': 'Event A',
        'reminders': [
          {'time': const TimeOfDay(hour: 10, minute: 0), 'description': 'Reminder 1'},
          {'time': const TimeOfDay(hour: 14, minute: 30), 'description': 'Reminder 2'},
        ]
      },
      {'name': 'Event B', 'reminders': []},
      {'name': 'Event C', 'reminders': []}
    ],
    DateTime(2024, 7, 27): [
      {'name': 'Event D', 'reminders': []}
    ],
    DateTime(2024, 8, 1): [
      {'name': 'Event E', 'reminders': []},
      {'name': 'Event F', 'reminders': []}
    ],
    DateTime(2024, 8, 3): [
      {'name': 'Event G', 'reminders': []}
    ],
    DateTime(2024, 8, 5): [
      {'name': 'Event H', 'reminders': []},
      {'name': 'Event I', 'reminders': []},
      {'name': 'Event J', 'reminders': []}
    ],
  };

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Calendar',
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.blueAccent),
                    onPressed: () {
                      _showSettingsDialog(context);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                eventLoader: _getEventsForDay,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(color: Colors.blueAccent),
                  selectedTextStyle: const TextStyle(color: Colors.white),
                  defaultTextStyle: const TextStyle(color: Colors.black87),
                  weekendTextStyle: const TextStyle(color: Colors.blueAccent),
                ),
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextStyle: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Colors.blueAccent,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Colors.blueAccent,
                  ),
                  headerPadding: EdgeInsets.symmetric(vertical: 15.0),
                ),
                selectedDayPredicate: (DateTime date) {
                  return isSameDay(_selectedDay, date);
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        right: 1,
                        bottom: 1,
                        child: _buildEventsMarker(events.length),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Selected Day:',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 134, 131, 131),
                    ),
                  ),
                  Text(
                    '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Calendar Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.event_note),
                title: const Text('View Events'),
                onTap: () {
                  Navigator.pop(context);
                  _showEventsDialog(context, _selectedDay);
                },
              ),
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: const Text('Change Theme'),
                onTap: () {
                  Navigator.pop(context);
                  // Show theme selection dialog or navigate to theme settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Reminders'),
                onTap: () {
                  Navigator.pop(context);
                  _showRemindersDialog(context, _selectedDay);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showEventsDialog(BuildContext context, DateTime selectedDay) {
    List<Map<String, dynamic>> events = _events[selectedDay] ?? [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              'Events on ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: events
                .map((event) => ListTile(
                      leading: const Icon(Icons.event),
                      title: Text(event['name']),
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showRemindersDialog(BuildContext context, DateTime selectedDay) {
    List<Map<String, dynamic>> events = _events[selectedDay] ?? [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reminders on ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: events
                .expand((event) => event['reminders'] as List<Map<String, dynamic>>)
                .map((reminder) => ListTile(
                      leading: const Icon(Icons.alarm),
                      title: Text('${reminder['time'].hour}:${reminder['time'].minute}'),
                      subtitle: Text(reminder['description']),
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                _addReminderDialog(context, selectedDay);
              },
              child: const Text('Add Reminder'),
            ),
          ],
        );
      },
    );
  }

  void _addReminderDialog(BuildContext context, DateTime selectedDay) {
    TimeOfDay selectedTime = TimeOfDay.now();
    String reminderDescription = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: const Text('Time'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (pickedTime != null && pickedTime != selectedTime) {
                      setState(() {
                        selectedTime = pickedTime;
                      });
                    }
                  },
                  child: Text('${selectedTime.hour}:${selectedTime.minute}'),
                ),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  reminderDescription = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // Add the reminder to the selected date's events
                  _events.update(
                    selectedDay,
                    (value) => [
                      ...value,
                      {
                        'name': 'Reminder',
                        'reminders': [
                          ...value.first['reminders'],
                          {
                            'time': selectedTime,
                            'description': reminderDescription,
                          }
                        ]
                      }
                    ],
                    ifAbsent: () => [],
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventsMarker(int eventCount) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blueAccent,
      ),
      width: 8.0,
      height: 8.0,
      child: Center(
        child: Text(
          '$eventCount',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8.0,
          ),
        ),
      ),
    );
  }
}

