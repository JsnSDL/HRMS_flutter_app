// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:hrm_employee/Screens/Loan/loan_type.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/button_global.dart';
import '../../GlobalComponents/purchase_model.dart';
import '../../constant.dart';

class LoanList extends StatefulWidget {
  const LoanList({Key? key}) : super(key: key);

  @override
  _LoanListState createState() => _LoanListState();
}

class _LoanListState extends State<LoanList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => const LoanType().launch(context),
        backgroundColor: kMainColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: kMainColor,
      appBar: AppBar(
        backgroundColor: kMainColor,
        elevation: 0.0,
        titleSpacing: 0.0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Loan List',
          maxLines: 2,
          style: kTextStyle.copyWith(
              color: Colors.white, fontWeight: FontWeight.bold),
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
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  Material(
                    elevation: 2.0,
                    child: GestureDetector(
                      onTap: () async {
                        // const DailyWorkReport().launch(context);
                        // bool isValid = await PurchaseModel().isActiveBuyer(); //commented  out the purchagre model
                        bool isValid = true;
                        if (isValid) {
                        } else {
                          showLicense(context: context);
                        }
                      },
                      child: Container(
                        width: context.width(),
                        padding: const EdgeInsets.all(10.0),
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: Color(0xFF7D6AEF),
                              width: 3.0,
                            ),
                          ),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Personal Loan',
                                  maxLines: 2,
                                  style: kTextStyle.copyWith(
                                      color: kTitleColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    color: kMainColor.withOpacity(0.1),
                                  ),
                                  child: const Icon(
                                    Icons.visibility_outlined,
                                    color: kMainColor,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Start Date: 01,May 2021',
                              style: kTextStyle.copyWith(
                                color: kGreyTextColor,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'End Date: 05,Dec 2021',
                                  style: kTextStyle.copyWith(
                                    color: kGreyTextColor,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Approved',
                                  style: kTextStyle.copyWith(
                                    color: kGreenColor,
                                  ),
                                ),
                                const SizedBox(
                                  width: 4.0,
                                ),
                                const CircleAvatar(
                                  radius: 10.0,
                                  backgroundColor: kGreenColor,
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Material(
                    elevation: 2.0,
                    child: GestureDetector(
                      onTap: () {
                        // const DailyWorkReport().launch(context);
                      },
                      child: Container(
                        width: context.width(),
                        padding: const EdgeInsets.all(10.0),
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: kAlertColor,
                              width: 3.0,
                            ),
                          ),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mobile Loan',
                              maxLines: 2,
                              style: kTextStyle.copyWith(
                                  color: kTitleColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Text(
                                  '(Apply Date) 15, May 2021',
                                  style: kTextStyle.copyWith(
                                    color: kGreyTextColor,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Pending',
                                  style: kTextStyle.copyWith(
                                    color: kAlertColor,
                                  ),
                                ),
                                const SizedBox(
                                  width: 4.0,
                                ),
                                const CircleAvatar(
                                  radius: 10.0,
                                  backgroundColor: kAlertColor,
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
