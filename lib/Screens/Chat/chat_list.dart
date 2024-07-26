// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant.dart';
import 'Model/lms_model.dart';
import 'Util/data_provider.dart';
import 'chat_inbox.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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
          title: Text(
            'Chat',
            style: kTextStyle.copyWith(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: AppTextField(
                  textFieldType: TextFieldType.NAME,
                  decoration: kInputDecoration.copyWith(
                    border: outlineInputBorder(),
                    fillColor: const Color(0xFFCCD8FC),
                    contentPadding: const EdgeInsets.only(left: 10.0),
                    hintText: 'Search',
                    suffixIcon: const Icon(
                      Icons.search,
                      color: kTitleColor,
                    ),
                  ),
                ),
              ),
              Container(
                width: context.width(),
                padding: const EdgeInsets.all(20.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                  color: Colors.white,
                ),
                child: Column(
                  children: list_data.map(
                    (data) {
                      return SettingItemWidget(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: data.title.validate(),
                        subTitle: data.subTitle.validate(),
                        leading: Image.network(data.image.validate(), height: 50, width: 50, fit: BoxFit.cover).cornerRadiusWithClipRRect(25),
                        trailing: Column(
                          children: [
                            Text('10.00 AM', style: secondaryTextStyle()),
                          ],
                        ),
                        onTap: () {
                          ChatInbox(img: data.image.validate(), name: data.title.validate()).launch(context);
                        },
                      );
                    },
                  ).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
