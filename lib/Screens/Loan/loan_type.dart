// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant.dart';
import 'loan_apply.dart';

class LoanType extends StatefulWidget {
  const LoanType({Key? key}) : super(key: key);

  @override
  _LoanTypeState createState() => _LoanTypeState();
}

class _LoanTypeState extends State<LoanType> {
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
              padding: const EdgeInsets.all(10.0),
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
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: const DecorationImage(image: AssetImage('images/personalloan.png'), fit: BoxFit.cover),
                    ),
                    child: ListTile(
                      title: Text(
                        'Personal Loan',
                        style: kTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Lorem ipsum dolor sit amet.',
                        style: kTextStyle.copyWith(color: Colors.white),
                      ),
                    ),
                  ).onTap(() => const LoanApply().launch(context)),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: const DecorationImage(image: AssetImage('images/carloan.png'), fit: BoxFit.cover),
                    ),
                    child: ListTile(
                      title: Text(
                        'Car Loan',
                        style: kTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Lorem ipsum dolor sit amet.',
                        style: kTextStyle.copyWith(color: Colors.white),
                      ),
                    ),
                  ).onTap(() => const LoanApply().launch(context)),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: const DecorationImage(image: AssetImage('images/mobileloan.png'), fit: BoxFit.cover),
                    ),
                    child: ListTile(
                      title: Text(
                        'Mobile Loan',
                        style: kTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Lorem ipsum dolor sit amet.',
                        style: kTextStyle.copyWith(color: Colors.white),
                      ),
                    ),
                  ).onTap(() => const LoanApply().launch(context)),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: const DecorationImage(image: AssetImage('images/homeloan.png'), fit: BoxFit.cover),
                    ),
                    child: ListTile(
                      title: Text(
                        'Home Loan',
                        style: kTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Lorem ipsum dolor sit amet.',
                        style: kTextStyle.copyWith(color: Colors.white),
                      ),
                    ),
                  ).onTap(() => const LoanApply().launch(context)),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: const DecorationImage(image: AssetImage('images/computerloan.png'), fit: BoxFit.cover),
                    ),
                    child: ListTile(
                      title: Text(
                        'Computer Loan',
                        style: kTextStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Lorem ipsum dolor sit amet.',
                        style: kTextStyle.copyWith(color: Colors.white),
                      ),
                    ),
                  ).onTap(() => const LoanApply().launch(context)),
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
