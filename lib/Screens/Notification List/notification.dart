import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hrm_employee/Screens/Birthday%20Notification/birthday_wish.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:hrm_employee/providers/user_provider.dart';
import 'package:hrm_employee/constant.dart';

class Notificationpage extends StatefulWidget {
  const Notificationpage({Key? key}) : super(key: key);

  @override
  State<Notificationpage> createState() => _NotificationpageState();
}

class _NotificationpageState extends State<Notificationpage> {
  late UserData userData;
  List<Employee> notifications = []; // Remove 'final' to allow mutation

  @override
  void initState() {
    super.initState();
    userData = Provider.of<UserData>(context, listen: false);
    fetchBirthday();
  }

  void filterNotifications() {
    setState(() {
      notifications.removeWhere((notification) {
        // Compare createdDate with current date
        return notification.createddate
            .isBefore(DateTime.now().subtract(Duration(days: 1)));
      });
    });
  }

  Future<void> fetchBirthday() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.5:3000/notification/getData'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userData.token}',
        },
        body: json.encode({
          'receiver_empcode': userData.userID,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['birthdayWishes'] != null) {
          List<Employee> fetchedNotifications =
              (jsonData['birthdayWishes'] as List)
                  .map((data) => Employee.fromJson(data))
                  .toList();
          setState(() {
            notifications.addAll(fetchedNotifications);
          });

          // Filter notifications based on createdDate
          filterNotifications();
        } else {
          print('No birthday wishes found');
        }
      } else {
        print('Failed to fetch notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (userData.userID == 'SDL001' || userData.userID == 'SDL002') ? const Color.fromARGB(255, 84, 27, 94) : kMainColor,
      appBar: AppBar(
        backgroundColor: (userData.userID == 'SDL001' || userData.userID == 'SDL002') ? const Color.fromARGB(255, 84, 27, 94) : kMainColor,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
        child: notifications.isEmpty
            ? const Center(
                child: Text(
                  'No notifications',
                  style: TextStyle(fontSize: 18.0, color: Colors.grey),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        return NotificationTile(
                          notification: notifications[index],
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final Employee notification;

  const NotificationTile({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnimatedBirthdayPage(
              name: notification.resceiverName,
              wish: notification.wish,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                notification.name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${notification.name} sent a birthday wish to you',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    notification.wish,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnimatedBirthdayPage(
                      name: notification.resceiverName,
                      wish: notification.wish,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      ),
    );
  }
}

class Employee {
  final String name;
  final String resceiverName;
  final String wish;
  final DateTime createddate;

  Employee({
    required this.name,
    required this.resceiverName,
    required this.wish,
    required this.createddate,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      name: json['senderName'],
      resceiverName: json['receiverName'],
      wish: json['receiverWish'],
      createddate: DateTime.parse(json['createdDate']),
    );
  }
}
