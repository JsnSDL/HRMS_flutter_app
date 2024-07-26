import 'package:flutter/material.dart';
import 'package:hrm_employee/providers/user_provider.dart';
import 'package:nb_utils/nb_utils.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../constant.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserData userData;
  String? userName;
  String? email;
  String? mobile;
  String? gender;
  String? photoUrl; 

  @override
  void initState() {
    super.initState();
    userData = Provider.of<UserData>(context, listen: false);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (userData.isTokenLoaded) {
        fetchUserData();
      } else {
        userData.addListener(() {
          if (userData.isTokenLoaded) {
            setState(() {
              fetchUserData();
            });
          }
        });
      }
    });
  }

  Future<void> fetchUserData() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.4:3000/auth/getUser'),
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
          final userDataJson = json.decode(response.body);
          userName = userDataJson['empName'];
          email = userDataJson['email'];
          mobile = userDataJson['mobile'];
          gender = userDataJson['gender'];
          photoUrl = json.decode(response.body)['photo'];
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (error) {
      // Handle error here, e.g., show a message to the user
      print('Error fetching user data: $error');
    }
  }

  Future<void> _refreshData() async {
    await fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kMainColor,
      appBar: AppBar(
        backgroundColor: kMainColor,
        elevation: 0.0,
        titleSpacing: 0.0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Profile',
          maxLines: 2,
          style: kTextStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        // actions: [
        //   GestureDetector(
        //     onTap: () {
        //       Navigator.of(context).push(
        //         MaterialPageRoute(
        //           builder: (context) => EditProfile(
        //             userName: userName ?? 'Loading..',
        //             email: email ?? 'Loading..',
        //             mobile: mobile ?? 'Loading..',
        //             gender: gender ?? 'Loading..',
        //             companyName: 'Sdlglobe Technologies Pvt Ltd',
        //             companyAddress:
        //                 'Geleyara Balaga Layout, Jalahalli West, Bengaluru, Myadarahalli, Karnataka 560090',
        //           ),
        //         ),
        //       );
        //     },
        //     child: Image(
        //       image: AssetImage('images/editprofile.png'),
        //     ),
        //   ),
        // ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.0),
            image(),
            Expanded(
              child: Container(
                width: context.width(),
                padding: const EdgeInsets.all(20.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20.0),
                      profileCard(
                        labelText: 'Company Name',
                        hintText: 'Sdlglobe Technologies Pvt Ltd',
                      ),
                      SizedBox(height: 20.0),
                      profileCard(
                        labelText: 'Employee name',
                        hintText: userName ?? 'Loading..',
                      ),
                      SizedBox(height: 20.0),
                      profileCard(
                        labelText: 'Email Address',
                        hintText: email ?? 'Loading..',
                      ),
                      SizedBox(height: 20.0),
                      profileCard(
                        labelText: 'Phone Number',
                        hintText: mobile ?? 'Loading..',
                      ),
                      SizedBox(height: 20.0),
                      profileCard(
                        labelText: 'Company Address',
                        hintText:
                            'Geleyara Balaga Layout, Jalahalli West, Bengaluru, Myadarahalli, Karnataka 560090',
                      ),
                      SizedBox(height: 20.0),
                      profileCard(
                        labelText: 'Gender',
                        hintText: gender ?? 'Loading..',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileCard({required String labelText, required String hintText}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          labelText,
          style: kTextStyle.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          hintText,
          style: kTextStyle.copyWith(color: Colors.grey),
        ),
      ),
    );
  }

  SizedBox image() {
    return SizedBox(
      width: double.infinity,
      height: 176,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: -50,
            right: 0,
            child: Container(
              height: 150,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
            ),
          ),
          Center(
            child:  CircleAvatar(
              radius: 70.0,
            backgroundImage:  photoUrl != null 
          ? NetworkImage(photoUrl!)
          : AssetImage('images/emp1.png') as ImageProvider<Object>?,),
          ),
        ],
      ),
    );
  }
}
