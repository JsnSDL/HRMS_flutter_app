// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant.dart';
// ignore_for_file: library_private_types_in_public_api

class DailyWorkReport extends StatefulWidget {
  const DailyWorkReport({Key? key}) : super(key: key);

  @override
  _DailyWorkReportState createState() => _DailyWorkReportState();
}

class _DailyWorkReportState extends State<DailyWorkReport> {
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kMainColor,
      appBar: AppBar(
        backgroundColor: kMainColor,
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Attendance Report',
          style: kTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: kTextStyle.copyWith(color: Colors.white),
                  ),
                  const SizedBox(
                    width: 4.0,
                  ),
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.white,
                  ),
                ],
              ),
            ).onTap(() => _selectDate(context)),
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
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                color: Color(0xFFFAFAFA),
              ),
              child: Column(
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
                          Row(
                            children: [
                              Expanded(
                                  child: Center(
                                      child: Text(
                                'Date',
                                style: kTextStyle.copyWith(fontWeight: FontWeight.bold),
                              ))),
                              Expanded(
                                  child: Center(
                                      child: Text(
                                'In Time',
                                style: kTextStyle.copyWith(fontWeight: FontWeight.bold),
                              ))),
                              Expanded(
                                  child: Center(
                                      child: Text(
                                'Out Time',
                                style: kTextStyle.copyWith(fontWeight: FontWeight.bold),
                              ))),
                              Expanded(
                                  child: Center(
                                      child: Text(
                                'Status',
                                style: kTextStyle.copyWith(fontWeight: FontWeight.bold),
                              ))),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Divider(
                              color: kBorderColorTextField,
                              thickness: 1.0,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Center(
                                        child: Text(
                                  '01-Jan-2022',
                                  style: kTextStyle.copyWith(color: kGreyTextColor, fontSize: 12.0),
                                ))),
                                Expanded(
                                    child: Center(
                                        child: Text(
                                  '10:30 PM',
                                  style: kTextStyle.copyWith(color: kGreyTextColor, fontSize: 12.0),
                                ))),
                                Expanded(
                                    child: Center(
                                        child: Text(
                                  '12:00 PM',
                                  style: kTextStyle.copyWith(color: kGreyTextColor, fontSize: 12.0),
                                ))),
                                Expanded(
                                    child: Center(
                                        child: Text(
                                  'P',
                                  style: kTextStyle.copyWith(color: Colors.green, fontSize: 18.0, fontWeight: FontWeight.bold),
                                ))),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Center(
                                        child: Text(
                                  '01-Jan-2022',
                                  style: kTextStyle.copyWith(color: kGreyTextColor, fontSize: 12.0),
                                ))),
                                Expanded(
                                    child: Center(
                                        child: Text(
                                  '10:30 PM',
                                  style: kTextStyle.copyWith(color: kGreyTextColor, fontSize: 12.0),
                                ))),
                                Expanded(
                                    child: Center(
                                        child: Text(
                                  '12:00 PM',
                                  style: kTextStyle.copyWith(color: kGreyTextColor, fontSize: 12.0),
                                ))),
                                Expanded(
                                    child: Center(
                                        child: Text(
                                  'A',
                                  style: kTextStyle.copyWith(color: Colors.redAccent, fontSize: 18.0, fontWeight: FontWeight.bold),
                                ))),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Center(
                                        child: Text(
                                  '01-Jan-2022',
                                  style: kTextStyle.copyWith(color: kGreyTextColor, fontSize: 12.0),
                                ))),
                                Expanded(
                                    child: Center(
                                        child: Text(
                                  '10:30 PM',
                                  style: kTextStyle.copyWith(color: kGreyTextColor, fontSize: 12.0),
                                ))),
                                Expanded(
                                    child: Center(
                                        child: Text(
                                  '12:00 PM',
                                  style: kTextStyle.copyWith(color: kGreyTextColor, fontSize: 12.0),
                                ))),
                                Expanded(
                                    child: Center(
                                        child: Text(
                                  'L',
                                  style: kTextStyle.copyWith(color: kAlertColor, fontSize: 18.0, fontWeight: FontWeight.bold),
                                ))),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Center(
                                        child: Text(
                                  '01-Jan-2022',
                                  style: kTextStyle.copyWith(color: kGreyTextColor, fontSize: 12.0),
                                ))),
                                Expanded(
                                    child: Center(
                                        child: Text(
                                  '10:30 PM',
                                  style: kTextStyle.copyWith(color: kGreyTextColor, fontSize: 12.0),
                                ))),
                                Expanded(
                                    child: Center(
                                        child: Text(
                                  '12:00 PM',
                                  style: kTextStyle.copyWith(color: kGreyTextColor, fontSize: 12.0),
                                ))),
                                Expanded(
                                    child: Center(
                                        child: Text(
                                  'H',
                                  style: kTextStyle.copyWith(color: kHalfDay, fontSize: 18.0, fontWeight: FontWeight.bold),
                                ))),
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
