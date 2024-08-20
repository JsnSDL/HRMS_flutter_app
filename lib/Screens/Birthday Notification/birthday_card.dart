import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hrm_employee/Screens/Birthday%20Notification/birthday_notification.dart';
import 'package:hrm_employee/Screens/Birthday%20Notification/birthday_wish.dart';
import 'package:hrm_employee/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:nb_utils/nb_utils.dart';

class BirthdayCardPage extends StatefulWidget {
  final Employee employee;

  const BirthdayCardPage({Key? key, required this.employee}) : super(key: key);

  @override
  _BirthdayCardPageState createState() => _BirthdayCardPageState();
}

class _BirthdayCardPageState extends State<BirthdayCardPage> {
  late UserData userData;
  String userName = "";
  final TextEditingController _wishController = TextEditingController();
  late String birthdayWish;

  @override
  void initState() {
    super.initState();
    userData = Provider.of<UserData>(context, listen: false);
    birthdayWish =
        'Wishing you a fantastic day filled with\njoy and happiness!';
    fetchUserName();
    print('Employee code: ${widget.employee.emplyoeecode}');
  }

  Future<void> fetchUserName() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.8:3000/auth/getUser'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userData.token}',
        },
        body: json.encode({
          'empcode': userData.userID,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          userName = json.decode(response.body)['empName'];
        });
        print('Fetched userName: $userName'); // Debug print
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (error) {
      print('Error fetching userName: $error');
      // Handle error here, e.g., show a message to the user
    }
  }

  void sendWish() async {
    Map<String, dynamic> wishValues = {
      'empcode': userData.userID,
      'fName': userName, // Ensure userName is populated correctly here
      'createdDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'receiverEmpcode': widget.employee.emplyoeecode,
      'receiverFName': widget.employee.name,
      'receiverWish': birthdayWish,
    };

    print('Sending wish with values: $wishValues');

    String jsonData = jsonEncode(wishValues);

    String url = 'http://192.168.1.8:3000/notification/send';

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
        print('Wish posted successfully');
        toast('Wish applied successfully');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BirthdayNotificationsPage()));
      } else {
        print('Failed to post wish: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception while posting Task: $e');
    }
  }

  @override
  void dispose() {
    _wishController.dispose();
    super.dispose();
  }

  Widget _buildFloatingBalls(BuildContext context) {
    return Stack(
      children: List.generate(100, (index) {
        return Positioned(
          left: Random().nextDouble() * MediaQuery.of(context).size.width,
          top: Random().nextDouble() * MediaQuery.of(context).size.height,
          child: _buildBall(
              Colors.primaries[Random().nextInt(Colors.primaries.length)]),
        );
      }),
    );
  }

  Widget _buildBall(Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(seconds: Random().nextInt(15) + 3),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -value * MediaQuery.of(context).size.height),
          child: Container(
            width: 20.0,
            height: 20.0,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        titleSpacing: 0.0,
        iconTheme: const IconThemeData(color: Colors.blue),
        title: const Text(
          'Birthday Card',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50, // Light blue gradient start
              Colors.blue.shade200, // Light blue gradient end
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildFloatingBalls(context),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAnimatedBirthdayCard(),
                    const SizedBox(height: 20.0),
                    _buildWishesAndIcon(),
                    const SizedBox(height: 20.0),
                    _buildSendButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBirthdayCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: _buildBirthdayCard(),
          ),
        );
      },
    );
  }

  Widget _buildBirthdayCard() {
    return Container(
      width: 300.0,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20.0),
          const Icon(
            Icons.cake,
            color: Colors.blue,
            size: 50.0,
          ),
          const SizedBox(height: 20.0),
          Text(
            'Happy Birthday, ${widget.employee.name}!',
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10.0),
          const Divider(
            color: Colors.blue,
            thickness: 2,
            height: 20,
            indent: 50,
            endIndent: 50,
          ),
          const SizedBox(height: 10.0),
          Text(
            birthdayWish,
            style: const TextStyle(
              fontSize: 18.0,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30.0),
          ElevatedButton.icon(
            onPressed: () => _showEditDialog(context),
            icon: const Icon(Icons.edit),
            label: const Text('Edit Wish'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishesAndIcon() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.park_outlined,
          color: Colors.blue,
          size: 24.0,
        ),
        SizedBox(width: 10.0),
        Text(
          'Send your warm wishes!',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(width: 10.0),
        Icon(
          Icons.card_giftcard,
          color: Colors.blue,
          size: 24.0,
        ),
      ],
    );
  }

  Widget _buildSendButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnimatedBirthdayPage(
              name: widget.employee.name,
              wish: birthdayWish,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Text(
          'Send Birthday Greeting',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    _wishController.text = birthdayWish;
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // Allow dismiss when tapping outside the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Birthday Wish'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _wishController,
                  decoration: const InputDecoration(
                    labelText: 'Enter your birthday wish',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  birthdayWish = _wishController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
