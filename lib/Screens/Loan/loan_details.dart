// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant.dart';

class LoanDetails extends StatefulWidget {
  const LoanDetails({Key? key}) : super(key: key);

  @override
  _LoanDetailsState createState() => _LoanDetailsState();
}

class _LoanDetailsState extends State<LoanDetails> {
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
          'Loan Details',
          maxLines: 2,
          style: kTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Image(
            image: AssetImage('images/employeesearch.png'),
          ),
        ],
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
                color: kBgColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  Material(
                    elevation: 2.0,
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      width: context.width(),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: context.width(),
                            padding: const EdgeInsets.all(20.0),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10.0),
                                topLeft: Radius.circular(10.0),
                              ),
                              color: kBgColor,
                            ),
                            child: Text(
                              'Below is your loan summary',
                              style: kTextStyle.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Loan Name',
                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                ),
                                Text(
                                  'Personal Loan',
                                  style: kTextStyle.copyWith(color: kTitleColor),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Loan Amount',
                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                ),
                                Text(
                                  '2000  Monthly',
                                  style: kTextStyle.copyWith(color: kTitleColor),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Installment',
                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                ),
                                Text(
                                  '06 Month',
                                  style: kTextStyle.copyWith(color: kTitleColor),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Start Date',
                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                ),
                                Text(
                                  '01,May 2021',
                                  style: kTextStyle.copyWith(color: kTitleColor),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'End Date',
                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                ),
                                Text(
                                  '01,Dec 2021',
                                  style: kTextStyle.copyWith(color: kTitleColor),
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            color: kBorderColorTextField,
                            thickness: 1.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Loan',
                                  style: kTextStyle.copyWith(color: kGreyTextColor, fontSize: 18.0, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '7000.00',
                                  style: kTextStyle.copyWith(color: kMainColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                                ),
                              ],
                            ),
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
