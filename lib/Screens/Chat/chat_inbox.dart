// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant.dart';
import 'Model/lms_model.dart';
import 'Util/data_provider.dart';

class ChatInbox extends StatefulWidget {
  final String? img;
  final String? name;

  // ignore: use_key_in_widget_constructors
  const ChatInbox({this.img, this.name});

  @override
  // ignore: library_private_types_in_public_api
  _ChatInboxState createState() => _ChatInboxState();
}

class _ChatInboxState extends State<ChatInbox> {
  ScrollController scrollController = ScrollController();

  TextEditingController messageController = TextEditingController();

  FocusNode msgFocusNode = FocusNode();

  List<LMSInboxData> data = maanInboxChatDataList();

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
    return Scaffold(
      backgroundColor: kMainColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leadingWidth: 24,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: kMainColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(radius: 20, backgroundImage: NetworkImage(widget.img.validate())),
            8.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name.validate(), style: boldTextStyle(color: Colors.white)),
                Text('Online', style: secondaryTextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
        actions: [
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(
              Icons.phone,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            width: 10.0,
          ),
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(
              Icons.video_call_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            width: 20.0,
          ),
        ],
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20.0,
            ),
            Container(
              width: context.width(),
              height: context.height(),
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  8.height,
                  Text('9:41 AM', style: secondaryTextStyle(size: 16)),
                  8.height,
                  ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    controller: scrollController,
                    scrollDirection: Axis.vertical,
                    reverse: true,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      if (data[index].id == 0) {
                        return Column(
                          children: [
                            8.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  decoration: boxDecorationWithRoundedCorners(
                                    backgroundColor: kMainColor,
                                    borderRadius: radius(12.0),
                                  ),
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text((data[index].message).validate(), style: primaryTextStyle(color: white)),
                                ),
                                8.width,
                                CircleAvatar(radius: 20, backgroundImage: NetworkImage(widget.img.validate())),
                              ],
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            8.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(radius: 20, backgroundImage: NetworkImage(widget.img.validate())),
                                8.width,
                                Container(
                                  decoration: boxDecorationWithRoundedCorners(
                                    borderRadius: radius(12.0),
                                    backgroundColor: Colors.grey.shade100,
                                  ),
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text((data[index].message).validate(), style: primaryTextStyle()),
                                ).paddingOnly(right: 42.0).expand(),
                              ],
                            ),
                          ],
                        ).paddingOnly(right: 32.0);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ).paddingTop(8.0),
      bottomNavigationBar: Container(
        padding: MediaQuery.of(context).viewInsets,
        decoration: boxDecorationWithRoundedCorners(
          backgroundColor: context.cardColor,
          borderRadius: radius(0.0),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              8.width,
              Icon(CupertinoIcons.smiley, size: 22, color: Colors.grey.shade600),
              4.width,
              Icon(Icons.image_outlined, size: 22, color: Colors.grey.shade600),
              4.width,
              Icon(Icons.mic_none, size: 22, color: Colors.grey.shade600),
              8.width,
              AppTextField(
                controller: messageController,
                textFieldType: TextFieldType.OTHER,
                focus: msgFocusNode,
                nextFocus: msgFocusNode,
                autoFocus: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Write a reply...',
                  hintStyle: secondaryTextStyle(size: 16),
                ),
              ).expand(),
              const Icon(Icons.send_outlined, size: 24, color: kMainColor).paddingAll(4.0).onTap(
                () {
                  if (messageController.text.isNotEmpty) {
                    addMessage();
                    messageController.clear();
                  }
                },
              ),
              8.width,
            ],
          ),
        ),
      ),
    );
  }

  void addMessage() {
    hideKeyboard(context);
    setState(
      () {
        data.insert(0, LMSInboxData(id: 0, message: messageController.text));
        if (mounted) scrollController.animToTop();
        FocusScope.of(context).requestFocus(msgFocusNode);
        setState(() {});
      },
    );
  }
}
