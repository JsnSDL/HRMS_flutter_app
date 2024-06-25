// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:hrm_employee/Screens/Attendance%20New%20Report/attendence_new_report.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant.dart';

class NewAttendenceReport extends StatefulWidget {
  const NewAttendenceReport({Key? key}) : super(key: key);

  @override
  _NewAttendenceReportState createState() => _NewAttendenceReportState();
}

class _NewAttendenceReportState extends State<NewAttendenceReport> {
  bool isOffice = true;
  List<String> reportList=[
    'Daliy Rep.',
    'Monthly Rep.'
  ];
  String selectedReport='Daliy Rep.';
  List<String> statusList=[
    'P',
    'A',
    'L',
    'W',
    'H',
    'H',
    'H',
    'H',
    'H'
  ];
  List<Color> colur=[
    const Color(0xff08BC85),
    const Color(0xffFF0505),
    const Color(0xffFF8919),
    const Color(0xff567DF4),
    const Color(0xff62E777),
    const Color(0xff62E777),
    const Color(0xff62E777),
    const Color(0xff62E777),
    const Color(0xff62E777),
  ];
  DateTime selectedDate=DateTime.now();
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
          'Attenda. Report',
          maxLines: 2,
          style: kTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white)
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      dropdownColor: kMainColor,
                      icon: const Icon(Icons.keyboard_arrow_down_outlined,color: Colors.white,),
                        value: selectedReport,
                        onChanged: (String?newValue){
                          setState(() {
                            selectedReport=newValue!;
                          });
                        },
                        items: reportList.map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e,style: TextStyle(color: Colors.white,),))).toList(),
                       ),
            ),
              ),
          ),
          )],
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
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      width: context.width(),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: const [
                            BoxShadow(
                              color: kDarkWhite,
                              offset: Offset(10, 10),
                              blurRadius: 10.0
                            )
                          ],
                          color: Colors.white),
                      child: Column(
                        children: [
                         selectedReport=='Daliy Rep.'?
                          // SingleChildScrollView(
                         //    scrollDirection: Axis.horizontal,
                         //    child: DataTable(
                         //        columns: const [
                         //          DataColumn(label: Text('Date')),
                         //          DataColumn(label: Text('In Time')),
                         //          DataColumn(label: Text('Out Time')),
                         //          DataColumn(label: Text('Status')),
                         //        ],
                         //        rows: List.generate(
                         //            statusList.length,
                         //                (index){
                         //                 return  DataRow(
                         //                     cells: [
                         //                       DataCell(
                         //                         Text('01-Jan-2022',style: kTextStyle.copyWith(color: kGreyTextColor),)
                         //                       ),
                         //                       DataCell(
                         //                         Text('10:30 PM',style: kTextStyle.copyWith(color: kGreyTextColor),)
                         //                       ),
                         //                       DataCell(
                         //                         Text('12:00 PM',style: kTextStyle.copyWith(color: kGreyTextColor),)
                         //                       ),
                         //                       DataCell(
                         //                         Text(statusList[index],style: kTextStyle.copyWith(color: colur[index],fontWeight: FontWeight.bold),)
                         //                       ),
                         //                     ]);
                         //                })),
                         //  )
                         Column(
                           children: [
                             const SizedBox(height: 10,),
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
                             ListView.builder(
                                 itemCount: statusList.length,
                                 shrinkWrap: true,
                                 physics: NeverScrollableScrollPhysics(),
                                 itemBuilder: (_,index){
                                   return Padding(
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
                                                   statusList[index],
                                                   style: kTextStyle.copyWith(color: colur[index], fontWeight: FontWeight.bold),
                                                 ))),
                                       ],
                                     ),
                                   );
                                 })
                           ],
                         )
                            :
                        Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                             children: [
                               const SizedBox(height: 8,),
                               // Text('${DateFormat.d().format(selectedDate)} ${DateFormat.MMM().format(selectedDate)} ${DateFormat.y().format(selectedDate)}'),
                               Text('03, November, 2021',style: kTextStyle.copyWith(fontWeight: FontWeight.bold,fontSize: 16),),
                               const SizedBox(height: 8,),
                               const Divider(
                                 color: kBorderColorTextField,
                                 thickness: 1.0,
                               ),
                               const SizedBox(height: 8,),
                               ListTile(
                                 visualDensity: const VisualDensity(horizontal: -4,vertical: -4),
                                 contentPadding: const EdgeInsets.symmetric(horizontal: 2,),
                                 leading: Container(
                                   height: 15,
                                   width: 15,
                                   decoration: const BoxDecoration(
                                     shape: BoxShape.circle,
                                     color: kMainColor
                                   ),
                                 ),
                                 title: Text('Working Days',style: kTextStyle.copyWith(color: kGreyTextColor),),
                                 trailing: Text('25 Days',style: kTextStyle.copyWith(color: kGreyTextColor),),
                               ),
                               ListTile(
                                 visualDensity: const VisualDensity(horizontal: -4,vertical: -4),
                                 contentPadding: const EdgeInsets.symmetric(horizontal: 2,),
                                 leading: Container(
                                   height: 15,
                                   width: 15,
                                   decoration: const BoxDecoration(
                                       shape: BoxShape.circle,
                                       color: Color(0xff08BC85)
                                   ),
                                 ),
                                 title: Text('Absent',style: kTextStyle.copyWith(color: kGreyTextColor),),
                                 trailing: Text('17 Days',style: kTextStyle.copyWith(color: kGreyTextColor),),
                               ),
                               ListTile(
                                 visualDensity: const VisualDensity(horizontal: -4,vertical: -4),
                                 contentPadding: const EdgeInsets.symmetric(horizontal: 2,),
                                 leading: Container(
                                   height: 15,
                                   width: 15,
                                   decoration: const BoxDecoration(
                                       shape: BoxShape.circle,
                                       color: Color(0xffFF8919)
                                   ),
                                 ),
                                 title: Text('Holiday',style: kTextStyle.copyWith(color: kGreyTextColor),),
                                 trailing: Text('10 Days',style: kTextStyle.copyWith(color: kGreyTextColor),),
                               ),
                               ListTile(
                                 visualDensity: const VisualDensity(horizontal: -4,vertical: -4),
                                 contentPadding: const EdgeInsets.symmetric(horizontal: 2,),
                                 leading: Container(
                                   height: 15,
                                   width: 15,
                                   decoration: const BoxDecoration(
                                       shape: BoxShape.circle,
                                       color: Color(0xffE8B500)
                                   ),
                                 ),
                                 title: Text('Half Day',style: kTextStyle.copyWith(color: kGreyTextColor),),
                                 trailing: Text('30 Days',style: kTextStyle.copyWith(color: kGreyTextColor),),
                               ),
                               ListTile(
                                 visualDensity: const VisualDensity(horizontal: -4,vertical: -4),
                                 contentPadding: const EdgeInsets.symmetric(horizontal: 2,),
                                 leading: Container(
                                   height: 15,
                                   width: 15,
                                   decoration: const BoxDecoration(
                                       shape: BoxShape.circle,
                                       color: Color(0xff9090AD)
                                   ),
                                 ),
                                 title: Text('Left Early',style: kTextStyle.copyWith(color: kGreyTextColor),),
                                 trailing: Text('15 Days',style: kTextStyle.copyWith(color: kGreyTextColor),),
                               ),
                               ListTile(
                                 visualDensity: const VisualDensity(horizontal: -4,vertical: -4),
                                 contentPadding: const EdgeInsets.symmetric(horizontal: 2,),
                                 leading: Container(
                                   height: 15,
                                   width: 15,
                                   decoration: const BoxDecoration(
                                       shape: BoxShape.circle,
                                       color: Color(0xff22215B)
                                   ),
                                 ),
                                 title: Text('Levae',style: kTextStyle.copyWith(color: kGreyTextColor),),
                                 trailing: Text('20 Days',style: kTextStyle.copyWith(color: kGreyTextColor),),
                               ),
                             ],
                         ),
                          )
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
