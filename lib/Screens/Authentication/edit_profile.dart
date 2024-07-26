// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:nb_utils/nb_utils.dart';
// import 'package:provider/provider.dart';

// import '../../GlobalComponents/button_global.dart';
// import '../../constant.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// import '../../providers/user_provider.dart';

// class EditProfile extends StatefulWidget {
//   final String companyName;
//   final String userName;
//   final String email;
//   final String mobile;
//   final String companyAddress;
//   final String gender;

//   const EditProfile({
//     Key? key,
//     required this.companyName,
//     required this.userName,
//     required this.email,
//     required this.mobile,
//     required this.companyAddress,
//     required this.gender,
//   }) : super(key: key);

//   @override
//   _EditProfileState createState() => _EditProfileState();
// }

// class _EditProfileState extends State<EditProfile> {
//   late UserData userData;
//   late String? editedCompanyName;
//   late String? editedUserName;
//   late String? editedEmail;
//   late String? editedMobile;
//   late String? editedCompanyAddress;
//   late String? editedGender;
//   final RegExp genderRegex = RegExp(r'^(?:MALE|FEMALE)$');

//   @override
//   void initState() {
//     super.initState();
//     // Initialize edited values with initial values passed from ProfileScreen
//     editedCompanyName = widget.companyName;
//     editedUserName = widget.userName;
//     editedEmail = widget.email;
//     editedMobile = widget.mobile;
//     editedCompanyAddress = widget.companyAddress;
//     editedGender = widget.gender;
//   }

//   void validateAndSetGender(String? value) {
//     setState(() {
//       if (genderRegex.hasMatch(value ?? '')) {
//         editedGender = value!.toUpperCase();
//       } else {
//         editedGender = '';
//       }
//     });
//   }

//   void _updateProfile() async {
//     Map<String, String> updateData = {
//       'empcode': userData.userID ?? '',
//       'userName': editedUserName ?? '',
//       'email': editedEmail ?? '',
//       'mobile': editedMobile ?? '',
//       'gender': editedGender ?? '',
//     };
//     String url = 'http://192.168.1.7:3000/auth/editUser';
//     print(updateData);
//     try {
//       final response = await http.post(Uri.parse(url),
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer ${userData.token}',
//           },
//           body: jsonEncode(updateData));
//       if (response.statusCode == 200) {
//         toast('user profile updated successfully');
//       } else {
//         toast('user profile updated failed');
//       }
//     } catch (e) {
//       toast('An unexpected error occurred. Please try again later');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     userData = Provider.of<UserData>(context, listen: false);
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       backgroundColor: kMainColor,
//       appBar: AppBar(
//         backgroundColor: kMainColor,
//         elevation: 0.0,
//         titleSpacing: 0.0,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: Text(
//           'Edit Profile',
//           maxLines: 2,
//           style: kTextStyle.copyWith(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           image(),
//           Expanded(
//             child: Container(
//               width: context.width(),
//               padding: const EdgeInsets.all(20.0),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//               ),
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 20.0),
//                     AppTextField(
//                       textFieldType: TextFieldType.NAME,
//                       initialValue: editedCompanyName ?? '',
//                       readOnly: true,
//                       onChanged: (value) {
//                         editedCompanyName = value;
//                       },
//                       decoration: const InputDecoration(
//                         labelText: 'Company Name',
//                         floatingLabelBehavior: FloatingLabelBehavior.always,
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 20.0),
//                     AppTextField(
//                       textFieldType: TextFieldType.NAME,
//                       initialValue: editedUserName ?? '',
//                       onChanged: (value) {
//                         editedUserName = value;
//                       },
//                       decoration: const InputDecoration(
//                         labelText: 'Employee name',
//                         floatingLabelBehavior: FloatingLabelBehavior.always,
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 20.0),
//                     AppTextField(
//                       textFieldType: TextFieldType.EMAIL,
//                       initialValue: editedEmail ?? '',
//                       onChanged: (value) {
//                         editedEmail = value;
//                       },
//                       decoration: const InputDecoration(
//                         labelText: 'Email Address',
//                         floatingLabelBehavior: FloatingLabelBehavior.always,
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 20.0),
//                     AppTextField(
//                       textFieldType: TextFieldType.PHONE,
//                       initialValue: editedMobile ?? '',
//                       onChanged: (value) {
//                         editedMobile = value;
//                       },
//                       decoration: InputDecoration(
//                         labelText: 'Phone Number',
//                         labelStyle: kTextStyle,
//                         border: const OutlineInputBorder(),
//                         floatingLabelBehavior: FloatingLabelBehavior.always,
//                       ),
//                     ),
//                     const SizedBox(height: 20.0),
//                     AppTextField(
//                       textFieldType: TextFieldType.NAME,
//                       initialValue: editedCompanyAddress ?? '',
//                       readOnly: true,
//                       onChanged: (value) {
//                         editedCompanyAddress = value;
//                       },
//                       decoration: const InputDecoration(
//                         labelText: 'Company Address',
//                         floatingLabelBehavior: FloatingLabelBehavior.always,
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 20.0),
//                     DropdownButtonFormField<String>(
//                       value: editedGender,
//                       onChanged: validateAndSetGender,
//                       items: ['MALE', 'FEMALE']
//                           .map((String value) => DropdownMenuItem<String>(
//                                 value: value,
//                                 child: Text(value),
//                               ))
//                           .toList(),
//                       decoration: const InputDecoration(
//                         labelText: 'Gender',
//                         floatingLabelBehavior: FloatingLabelBehavior.always,
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 20.0),
//                     ButtonGlobal(
//                       buttontext: 'Update',
//                       buttonDecoration:
//                           kButtonDecoration.copyWith(color: kMainColor),
//                       onPressed: () {
//                         _updateProfile();
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   SizedBox image() {
//     return SizedBox(
//       width: double.infinity,
//       height: 176,
//       child: Stack(
//         children: [
//           Positioned(
//             left: 0,
//             bottom: -50,
//             right: 0,
//             child: Container(
//               height: 150,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(30),
//                   topRight: Radius.circular(30),
//                 ),
//               ),
//             ),
//           ),
//           Center(
//             child: Container(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(250),
//                 child: Image.asset(
//                   'images/userprofileimage.jpg',
//                   fit: BoxFit.cover,
//                   width: 150,
//                   height: 150,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
