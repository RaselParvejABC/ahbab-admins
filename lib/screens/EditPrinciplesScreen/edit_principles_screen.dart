import 'package:ahbabadmin/auth/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/getwidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditPrinciplesScreen extends StatefulWidget {
  static String get label => "মূলনীতি এডিট";
  static String get requiredAdminPrivilege => "principles-edit";
  static String get routeName => "EditPrinciplesScreen";
  const EditPrinciplesScreen({Key? key}) : super(key: key);

  @override
  State<EditPrinciplesScreen> createState() => _EditPrinciplesScreenState();
}

class _EditPrinciplesScreenState extends State<EditPrinciplesScreen> {
  final _editPrinciplesFormKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();

  late DocumentSnapshot principlesDocSnap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(EditPrinciplesScreen.label),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('ahbabVariables').doc('principles').get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text(
              'কিছু একটা সমস্যা হয়েছে। এ্যাপ বন্ধ করে ইন্টারনেট সংযোগ চেক করে আবার চেষ্টা করুন।',
            );
          }
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            principlesDocSnap = snapshot.data as DocumentSnapshot;
            if (principlesDocSnap.exists) {
              _titleController.text = principlesDocSnap.get('title');
              _detailsController.text = principlesDocSnap.get('principles');
            }
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Form(
                    key: _editPrinciplesFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 16.0,
                        ),
                        const Text(
                          'মূলনীতি সম্পাদনা করুন',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (!_editPrinciplesFormKey.currentState!.validate()) {
                              await showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('ভুল হচ্ছে।'),
                                    content: const Text('সব তথ্য ঠিকঠাক পূরণ করেননি।'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('বেশ!'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              return;
                            }

                            String loginStatus = await checkSessionKey();
                            if (loginStatus != '') {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.clear();
                              Navigator.pushReplacementNamed(context, 'LogInScreen');
                            }

                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                return const AlertDialog(
                                  title: Text('কিছুক্ষণ অপেক্ষা করুন।'),
                                  content: LinearProgressIndicator(
                                    value: null,
                                  ),
                                );
                              },
                            );

                            Map<String, dynamic> principlesData = {
                              'title': _titleController.text,
                              'principles': _detailsController.text,
                            };

                            principlesDocSnap.reference.set(principlesData).then((value) {
                              Navigator.of(context).pop();
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('সফল'),
                                    content: const Text('তথ্য ডাটাবেসে জমা হয়েছে।'),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            setState(() {});
                                          },
                                          child: const Text('ওকে।')),
                                    ],
                                  );
                                },
                              );
                            }, onError: (error) {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) => AlertDialog(
                                    title: const Text('ব্যর্থ'),
                                    content: const Text('তথ্য ডাটাবেসে জমা হয়নি।'),
                                    actions: [
                                      TextButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            setState(() {});
                                          },
                                          child: const Text('ওকে।')),
                                    ],
                                  ),
                              );
                            });
                          },
                          child: const Text(
                            'ডাটাবেসে সেভ করুন',
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _titleController,
                                  decoration: const InputDecoration(
                                    labelText: 'শিরোনাম',
                                  ),
                                  validator: (value) {
                                    value = value?.trim();
                                    if (value == null || value.isEmpty) {
                                      return 'শিরোনামের ঘর খালি রেখেছেন।';
                                    }
                                    _titleController.text = value;
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: _detailsController,
                                  minLines: 3,
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                    labelText: 'মূলনীতিসমূহ',
                                  ),
                                  validator: (value) {
                                    value = value?.trim();
                                    if (value == null || value.isEmpty) {
                                      return 'মূলনীতির ঘর খালি রেখেছেন।';
                                    }
                                    _detailsController.text = value;
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return const GFLoader(
            type: GFLoaderType.square,
          );
        },
      ),
    );
  }
}
