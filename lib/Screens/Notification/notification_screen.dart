import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:nb_utils/nb_utils.dart';

import '../../constant.dart';
import '../Chat/Model/lms_model.dart';
import '../Chat/Util/data_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // ignore: non_constant_identifier_names
  List<LMSModel> list_data = maanGetChatList();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kMainColor,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: kMainColor,
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            'Notification',
            style: kTextStyle.copyWith(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Today',
                        style: kTextStyle.copyWith(color: kTitleColor, fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Column(
                      children: list_data.map(
                        (data) {
                          return SettingItemWidget(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: data.title.validate(),
                            subTitle: '5 min ago',
                            leading: Image.network(data.image.validate(), height: 50, width: 50, fit: BoxFit.cover).cornerRadiusWithClipRRect(25),
                            trailing: Container(
                              height: 10.0,
                              width: 10.0,
                              decoration: BoxDecoration(
                                color: kMainColor,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            onTap: () {},
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
