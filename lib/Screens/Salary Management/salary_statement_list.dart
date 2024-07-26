// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:hrm_employee/Screens/Salary%20Management/salary_statement_details.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../constant.dart';

class SalaryStatementList extends StatefulWidget {
  const SalaryStatementList({Key? key}) : super(key: key);

  @override
  _SalaryStatementListState createState() => _SalaryStatementListState();
}

class _SalaryStatementListState extends State<SalaryStatementList> {
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  List<String> dateList=[
    '03, July 2021',
    '05, Fub 2021',
    '01, Mur 2021'
  ];
  List<String> amountList=[
    '16,000',
    '20,000',
    '30,000'
  ];

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
          'Salary Statement',
          // maxLines: 2,
          style: kTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 18),
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
              width: context.width(),
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: amountList.length,
                    itemBuilder: (_,i){
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: GestureDetector(
                          onTap: () {
                            const SalaryStatementDetails().launch(context);
                          },
                          child: Material(
                            borderRadius: BorderRadius.circular(10),
                            elevation: 2.0,
                            child: Container(
                              width: context.width(),
                              padding: const EdgeInsets.all(10.0),
                              decoration:  BoxDecoration(
                                border: const Border(
                                  left: BorderSide(
                                    color: Color(0xff08BC85),
                                    width: 3.0,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: kDarkWhite,
                                    spreadRadius: 2.0,
                                    offset: Offset(5, 5),
                                    blurRadius: 10.0
                                  )
                                ]
                              ),
                              child:  Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(dateList[i],style: kTextStyle.copyWith(fontWeight: FontWeight.bold),),
                                      const Spacer(),
                                      Column(
                                        children: [
                                          Text(amountList[i],style: kTextStyle.copyWith(fontWeight: FontWeight.bold),),
                                          SizedBox(height: 5,),
                                          Container(
                                            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10.0),
                                              color: kMainColor,
                                            ),
                                            child: Text(
                                              'View',
                                              style: kTextStyle.copyWith(color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 10.0,
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
