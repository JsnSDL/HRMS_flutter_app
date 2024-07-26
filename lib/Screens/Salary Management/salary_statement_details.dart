// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant.dart';

class SalaryStatementDetails extends StatefulWidget {
  const SalaryStatementDetails({Key? key}) : super(key: key);

  @override
  _SalaryStatementDetailsState createState() => _SalaryStatementDetailsState();
}

class _SalaryStatementDetailsState extends State<SalaryStatementDetails> {
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
          'Salary Details',
          maxLines: 2,
          style: kTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 19),
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
                      padding: const EdgeInsets.all(10.0),
                      width: context.width(),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'Particulars',
                                    style: kTextStyle,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'Amount(+)',
                                    style: kTextStyle,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'Amount(-)',
                                    style: kTextStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            color: kBorderColorTextField,
                            thickness: 1.0,
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Basic',
                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '12,000.00',
                                    style: kTextStyle,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '-',
                                    style: kTextStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Conveyance',
                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '3,000.00',
                                    style: kTextStyle,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '-',
                                    style: kTextStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Entertainment',
                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '2,000.00',
                                    style: kTextStyle,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '-',
                                    style: kTextStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'House Rent',
                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '2,000.00',
                                    style: kTextStyle,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '-',
                                    style: kTextStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Medical Allowance',
                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '1,000.00',
                                    style: kTextStyle,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '-',
                                    style: kTextStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Overtime',
                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '5,000.00',
                                    style: kTextStyle,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '-',
                                    style: kTextStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Deductions',
                                      style: kTextStyle,
                                    ),
                                    Text(
                                      'Absent (8 Days)',
                                      style: kTextStyle.copyWith(color: kGreyTextColor),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '-',
                                    style: kTextStyle,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '3000.00',
                                    style: kTextStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Deductions',
                                      style: kTextStyle,
                                    ),
                                    Text(
                                      'Advance Salary',
                                      style: kTextStyle.copyWith(color: kGreyTextColor),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '-',
                                    style: kTextStyle,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '5000.00',
                                    style: kTextStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Subtotal',
                                  style: kTextStyle.copyWith(fontWeight: FontWeight.bold,fontSize: 13),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '24,000.00',
                                    style: kTextStyle.copyWith(fontWeight: FontWeight.bold,fontSize: 13),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '8000.00',
                                    style: kTextStyle.copyWith(fontWeight: FontWeight.bold,fontSize: 13),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          const Divider(
                            color: kBorderColorTextField,
                            thickness: 1.0,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'Total Pay Salary',
                                    style: kTextStyle.copyWith(fontWeight: FontWeight.bold,fontSize: 13),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '16,000.00',
                                    style: kTextStyle.copyWith(fontWeight: FontWeight.bold,fontSize: 13),
                                  ),
                                ),
                              ),
                              const Expanded(child: Text(''))
                            ],
                          ),
                          const SizedBox(
                            height: 15.0,
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
