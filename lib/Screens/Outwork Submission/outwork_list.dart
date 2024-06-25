import 'package:flutter/material.dart';
import 'package:hrm_employee/Screens/Outwork%20Submission/submit_outwork.dart';
// ignore: depend_on_referenced_packages
import 'package:nb_utils/nb_utils.dart';

import '../../constant.dart';

class OutworkList extends StatefulWidget {
  const OutworkList({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _OutworkListState createState() => _OutworkListState();
}

class _OutworkListState extends State<OutworkList> {
  List<String> types = ['All', 'Pending', 'In Progress', 'Completed', 'Rejected'];
  String selected = 'All';
  Color getColor() {
    switch (selected) {
      case 'Pending':
        return kAlertColor;
      case 'In Progress':
        return kMainColor;
      case 'Completed':
        return kGreenColor;
      case 'Rejected':
        return Colors.redAccent;
      default:
        return kAlertColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => const OutworkSubmission().launch(context),
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
          'Outwork Submission',
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
                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                      color: Colors.white,
                    ),
                    child: HorizontalList(
                      spacing: 0,
                      itemCount: types.length,
                      itemBuilder: (_, i) {
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            types[i],
                            style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: selected == types[i] ? kMainColor : kGreyTextColor),
                          ).onTap(() {
                            setState(() {
                              selected = types[i];
                            });
                          }),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
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
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: getColor(),
                              width: 3.0,
                            ),
                          ),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start New Web UI Design',
                              maxLines: 2,
                              style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'Work Start',
                                      style: kTextStyle.copyWith(
                                        color: kGreyTextColor,
                                      ),
                                    ),
                                    Text(
                                      '01,May 2021',
                                      style: kTextStyle.copyWith(color: kGreyTextColor, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Work End',
                                      style: kTextStyle.copyWith(
                                        color: kGreyTextColor,
                                      ),
                                    ),
                                    Text(
                                      '01,May 2021',
                                      style: kTextStyle.copyWith(color: kGreyTextColor, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Text(
                                  selected == 'All' ? 'Pending' : selected,
                                  style: kTextStyle.copyWith(color: getColor()),
                                )
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
