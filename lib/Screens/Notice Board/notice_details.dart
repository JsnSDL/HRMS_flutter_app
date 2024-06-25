// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant.dart';

class NoticeDetails extends StatefulWidget {
  const NoticeDetails({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _NoticeDetailsState createState() => _NoticeDetailsState();
}

class _NoticeDetailsState extends State<NoticeDetails> {
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
          'View Notice',
          maxLines: 2,
          style: kTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20.0,
            ),
            Container(
              width: context.width(),
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: Image.asset('images/emp1.png'),
                            title: Text(
                              'Sahidul islam',
                              style: kTextStyle,
                            ),
                            subtitle: Text(
                              'Admin',
                              style: kTextStyle.copyWith(color: kGreyTextColor),
                            ),
                            trailing: Text(
                              '19 July, 2022',
                              style: kTextStyle.copyWith(color: kGreyTextColor),
                            ),
                          ),
                          Divider(
                            color: kBorderColorTextField.withOpacity(0.2),
                            thickness: 1,
                          ),
                          Text(
                            'Holy Eid-Ul-Adha',
                            style: kTextStyle.copyWith(fontSize: 18.0),
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          Text(
                            'Dear Valuable Partners,',
                            style: kTextStyle.copyWith(color: kGreyTextColor),
                          ),
                          const SizedBox(
                            height: 1.0,
                          ),
                          Text(
                            'For your information, our office will be closed from 19-07-2021 to 24-07-2021 due to the occa-sion of Holy Eid-Ul-Adha. Our office activities will resume from 25-07-2021 July as before.',
                            style: kTextStyle.copyWith(color: kGreyTextColor),
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          Text(
                            'Thanks',
                            style: kTextStyle.copyWith(color: kGreyTextColor),
                          ),
                          Text(
                            'MD Shahidul Islam',
                            style: kTextStyle.copyWith(color: kGreyTextColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: Image.asset('images/emp1.png'),
                            title: Text(
                              'Sahidul islam',
                              style: kTextStyle,
                            ),
                            subtitle: Text(
                              'Admin',
                              style: kTextStyle.copyWith(color: kGreyTextColor),
                            ),
                            trailing: Text(
                              '19 July, 2022',
                              style: kTextStyle.copyWith(color: kGreyTextColor),
                            ),
                          ),
                          Divider(
                            color: kBorderColorTextField.withOpacity(0.2),
                            thickness: 1,
                          ),
                          Text(
                            'Holy Eid-Ul-Adha',
                            style: kTextStyle.copyWith(fontSize: 18.0),
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          Text(
                            'Dear Valuable Partners,',
                            style: kTextStyle.copyWith(color: kGreyTextColor),
                          ),
                          const SizedBox(
                            height: 1.0,
                          ),
                          Text(
                            'For your information, our office will be closed from 19-07-2021 to 24-07-2021 due to the occa-sion of Holy Eid-Ul-Adha. Our office activities will resume from 25-07-2021 July as before.',
                            style: kTextStyle.copyWith(color: kGreyTextColor),
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          Text(
                            'Thanks',
                            style: kTextStyle.copyWith(color: kGreyTextColor),
                          ),
                          Text(
                            'MD Shahidul Islam',
                            style: kTextStyle.copyWith(color: kGreyTextColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: Image.asset('images/emp1.png'),
                            title: Text(
                              'Sahidul islam',
                              style: kTextStyle,
                            ),
                            subtitle: Text(
                              'Admin',
                              style: kTextStyle.copyWith(color: kGreyTextColor),
                            ),
                            trailing: Text(
                              '19 July, 2022',
                              style: kTextStyle.copyWith(color: kGreyTextColor),
                            ),
                          ),
                          Divider(
                            color: kBorderColorTextField.withOpacity(0.2),
                            thickness: 1,
                          ),
                          Text(
                            'Holy Eid-Ul-Adha',
                            style: kTextStyle.copyWith(fontSize: 18.0),
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          Text(
                            'Dear Valuable Partners,',
                            style: kTextStyle.copyWith(color: kGreyTextColor),
                          ),
                          const SizedBox(
                            height: 1.0,
                          ),
                          Text(
                            'For your information, our office will be closed from 19-07-2021 to 24-07-2021 due to the occa-sion of Holy Eid-Ul-Adha. Our office activities will resume from 25-07-2021 July as before.',
                            style: kTextStyle.copyWith(color: kGreyTextColor),
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          Text(
                            'Thanks',
                            style: kTextStyle.copyWith(color: kGreyTextColor),
                          ),
                          Text(
                            'MD Shahidul Islam',
                            style: kTextStyle.copyWith(color: kGreyTextColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
