import 'package:ahbabadmin/dialogs/inform_dialog.dart';
import 'package:ahbabadmin/dialogs/wait_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:regexpattern/regexpattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'list_of_notices.dart';

class NoticeBoardManagementScreen extends StatelessWidget {

  static String get label => "নোটিশ বোর্ড ব্যবস্থাপনা";
  static String get requiredAdminPrivilege => "notice-board-management";
  static String get routeName => "NoticeBoardManagementScreen";

  final _formKey = GlobalKey<FormState>();
  final _noticeTitleController = TextEditingController();
  final _noticeBodyController = TextEditingController();
  final _noticeToController = TextEditingController();

  NoticeBoardManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(NoticeBoardManagementScreen.label),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        'নতুন নোটিশ লিখুন',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                        ),
                      ),
                      TextFormField(
                        controller: _noticeTitleController,
                        decoration: const InputDecoration(
                          labelText: 'নোটিশের শিরোনাম',
                          helperText: 'সংক্ষিপ্ত রাখুন',
                        ),
                        validator: (value) {
                          value = value?.trim();
                          if (value == null || value.isEmpty) {
                            return 'শিরোনাম লিখুন।';
                          }
                          _noticeTitleController.text = value;
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _noticeBodyController,
                        minLines: 2,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'নোটিশের বিস্তারিত',
                        ),
                        validator: (value) {
                          value = value?.trim();
                          if (value == null || value.isEmpty) {
                            return 'বিস্তারিত লিখুন।';
                          }
                          _noticeBodyController.text = value;
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _noticeToController,
                        minLines: 1,
                        maxLines: 2,
                        decoration: const InputDecoration(
                            labelText: 'যে সদস্য বা সদস্যদের প্রতি নোটিশ, তাঁদের সদস্য নম্বর',
                            helperText: 'সবাইকে বুঝাতে 1000 লিখুন। একাধিক সদস্য নম্বর স্পেস দিয়ে আলাদা করে লিখুন।'),
                        validator: (value) {
                          value = value?.trim();
                          if (value == null || value.isEmpty) {
                            return 'কাদের প্রতি নোটিশ, তা লিখেননি।';
                          }
                          _noticeToController.text = value;
                          List<String> values = value.split(RegExp(r"\s+"));
                          //values.forEach((element) {print(element);});
                          if (!values.every((element) => element.isNumeric())) {
                            return 'এই ঘরে শুধু স্পেস ও ইংরেজি ডিজিট থাকবে।';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      ElevatedButton(
                        child: const Text('ডাটাবেসে সেভ করুন'),
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          showWaitDialog(context);

                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
                          Map<String, dynamic> data = {
                            'title': _noticeTitleController.text,
                            'body': _noticeBodyController.text,
                            'to': _noticeToController.text.split(RegExp(r"\s+")),
                            'byAdmin': prefs.getString('username')!,
                            'timestamp': timestamp,
                          };

                          FirebaseFirestore.instance.collection('notices').doc(timestamp).set(data).then(
                            (value) {
                              Navigator.of(context).pop();
                              showInformDialog(context, 'সফল', 'নোটিশ ডাটাবেসে সেভ হয়েছে। নোটিফিকেশন পাঠাতে বেল আইকন চাপুন।');
                              _formKey.currentState!.reset();
                            },
                            onError: (error) {
                              Navigator.of(context).pop();
                              showInformDialog(context, 'ব্যর্থ', 'নোটিশ ডাটাবেসে সেভ হয়নি। এ্যাপ বন্ধ করে ইন্টারনেট সংযোগ চেক করে আবার চেষ্টা করুন।');
                            },
                          );

                        },
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      const ListOfNotices(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
