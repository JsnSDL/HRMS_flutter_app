// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:hrm_employee/Screens/Authentication/sign_in.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant.dart';

class SelectType extends StatefulWidget {
  const SelectType({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SelectTypeState createState() => _SelectTypeState();
}

class _SelectTypeState extends State<SelectType> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //// const Image(image: AssetImage("images/logo.png")),
                const Image( 
                  image: AssetImage("images/smart_h2r.png"),
                  width: 250,
                ),
                const SizedBox(
                  height: 100.0,
                ),
                const Image(image: AssetImage("images/people.png")),             
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: kGreyTextColor),
                      color: Colors.white,
                    ),
                    child: ListTile(
                      onTap: () {
                        const SignIn().launch(context);
                      },
                      leading: const Image(
                        image: AssetImage('images/employee.png'),
                      ),
                      title: Text(
                        'Employee',
                        style: kTextStyle.copyWith(fontSize: 14.0),
                      ),
                      subtitle: Text(
                        'Register and start marking your attendance',
                        style: kTextStyle.copyWith(
                            color: kGreyTextColor, fontSize: 12.0),
                      ),
                       trailing: IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          size: 15.0,
                        ),
                        onPressed: () {
                          const SignIn().launch(context);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }
}
