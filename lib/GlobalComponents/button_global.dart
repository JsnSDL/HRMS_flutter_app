import 'package:flutter/material.dart';

import '../constant.dart';

// ignore: must_be_immutable
class ButtonGlobal extends StatelessWidget {
  final String buttontext;
  final Decoration buttonDecoration;
  // ignore: prefer_typing_uninitialized_variables
  var onPressed;

  // ignore: use_key_in_widget_constructors
  ButtonGlobal({required this.buttontext, required this.buttonDecoration, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        decoration: buttonDecoration,
        child: Center(
          child: Text(
            buttontext,
            style: kTextStyle.copyWith(fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class ButtonGlobalWithoutIcon extends StatelessWidget {
  final String buttontext;
  final Decoration buttonDecoration;
  // ignore: prefer_typing_uninitialized_variables
  var onPressed;
  final Color buttonTextColor;

  // ignore: use_key_in_widget_constructors
  ButtonGlobalWithoutIcon({required this.buttontext, required this.buttonDecoration, required this.onPressed, required this.buttonTextColor});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
        decoration: buttonDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              buttontext,
              style: kTextStyle.copyWith(color: buttonTextColor),
            ),
          ],
        ),
      ),
    );
  }
}


void showLicense({required BuildContext context}){
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Container(
            height: 180.0,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text('Please Check Your Purchase Code',style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
                      SizedBox(height: 10.0,),
                      Text('Your purchase code is not valid. Please buy our product from envato to get a new purchase code',maxLines: 6,),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}