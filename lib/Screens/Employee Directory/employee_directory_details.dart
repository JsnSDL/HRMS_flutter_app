// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant.dart';

class EmployeeDetails extends StatefulWidget {
  const EmployeeDetails({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EmployeeDetailsState createState() => _EmployeeDetailsState();
}

class _EmployeeDetailsState extends State<EmployeeDetails> {
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
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Image.asset('images/emp1.png'),
          title: Text(
            'Sahidul islam',
            style: kTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Designer',
            style: kTextStyle.copyWith(color: Colors.white.withOpacity(0.5)),
          ),
          trailing: const Icon(
            Icons.close,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20.0,
          ),
          Expanded(
            child: Container(
              width: context.width(),
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                color: Color(0xFFFAFAFA),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  Material(
                    elevation: 2.0,
                    borderRadius: BorderRadius.circular(20.0),
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            'Personal Information',
                            style: kTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 20.0),
                          ),
                          const SizedBox(
                            height: 30.0,
                          ),
                          AppTextField(
                            textFieldType: TextFieldType.EMAIL,
                            readOnly: true,
                            controller: TextEditingController(text: 'maantheme@maantheme.com'),
                            decoration: const InputDecoration(
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelText: 'Email Address',
                              hintText: 'maantheme@maantheme.com',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          AppTextField(
                            textFieldType: TextFieldType.PHONE,
                            readOnly: true,
                            controller: TextEditingController(text: '017563985345'),
                            decoration: const InputDecoration(
                              labelText: 'Contact No.',
                              hintText: '017674355654',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          AppTextField(
                            textFieldType: TextFieldType.NAME,
                            readOnly: true,
                            controller: TextEditingController(text: 'Designer'),
                            decoration: const InputDecoration(
                              labelText: 'Designation',
                              hintText: 'Designer',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          AppTextField(
                            textFieldType: TextFieldType.NAME,
                            readOnly: true,
                            controller: TextEditingController(text: 'Bangladeshi'),
                            decoration: const InputDecoration(
                              labelText: 'Nationality',
                              hintText: 'Bangladeshi',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          AppTextField(
                            textFieldType: TextFieldType.NAME,
                            readOnly: true,
                            controller: TextEditingController(text: 'Male'),
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                              hintText: 'Male',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
