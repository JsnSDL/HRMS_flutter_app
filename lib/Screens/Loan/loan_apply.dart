// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:hrm_employee/GlobalComponents/button_global.dart';
import 'package:hrm_employee/Screens/Loan/loan_details.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant.dart';
import 'loan_type.dart';

class LoanApply extends StatefulWidget {
  const LoanApply({Key? key}) : super(key: key);

  @override
  _LoanApplyState createState() => _LoanApplyState();
}

class _LoanApplyState extends State<LoanApply> {
  final dateController = TextEditingController();
  List<String> numberOfInstallment = ['3 Month', '6 month', '12 Month', '36 Month', '48 Month'];
  String installment = '3 Month';
  DropdownButton<String> getInstallment() {
    List<DropdownMenuItem<String>> dropDownItems = [];
    for (String installment in numberOfInstallment) {
      var item = DropdownMenuItem(
        value: installment,
        child: Text(installment),
      );
      dropDownItems.add(item);
    }
    return DropdownButton(
      items: dropDownItems,
      value: installment,
      onChanged: (value) {
        setState(() {
          installment = value!;
        });
      },
    );
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

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
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    decoration: kInputDecoration.copyWith(
                      labelText: 'Client Name',
                      hintText: 'MaanTheme',
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    decoration: kInputDecoration.copyWith(
                      labelText: 'Loan Name',
                      hintText: 'Personal Loan',
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  AppTextField(
                    textFieldType: TextFieldType.PHONE,
                    decoration: kInputDecoration.copyWith(
                      labelText: 'Loan AMount',
                      hintText: '\$1000',
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  SizedBox(
                    height: 60.0,
                    child: FormField(
                      builder: (FormFieldState<dynamic> field) {
                        return InputDecorator(
                          decoration: InputDecoration(
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelText: 'Client Type',
                              labelStyle: kTextStyle,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                          child: DropdownButtonHideUnderline(child: getInstallment()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          textFieldType: TextFieldType.NAME,
                          readOnly: true,
                          onTap: () async {
                            var date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime(2100));
                            dateController.text = date.toString().substring(0, 10);
                          },
                          controller: dateController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              suffixIcon: Icon(
                                Icons.date_range_rounded,
                                color: kGreyTextColor,
                              ),
                              labelText: 'Start Date',
                              hintText: '11/09/2021'),
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: AppTextField(
                          textFieldType: TextFieldType.NAME,
                          readOnly: true,
                          onTap: () async {
                            var date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime(2100));
                            dateController.text = date.toString().substring(0, 10);
                          },
                          controller: dateController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              suffixIcon: Icon(
                                Icons.date_range_rounded,
                                color: kGreyTextColor,
                              ),
                              labelText: 'End Date',
                              hintText: '11/09/2021'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  ButtonGlobal(
                    buttontext: 'Apply',
                    buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
                    onPressed: () => const LoanDetails().launch(context),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
