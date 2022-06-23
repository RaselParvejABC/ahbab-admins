import 'package:ahbabadmin/auth/cryptography.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class EditAdminsScreen extends StatefulWidget {
  static String get label => "এডমিন এডিট";
  static String get requiredAdminPrivilege => "admin-edit";
  static String get routeName => "EditAdminsScreen";
  const EditAdminsScreen({Key? key}) : super(key: key);

  @override
  _EditAdminsScreenState createState() => _EditAdminsScreenState();
}

class _EditAdminsScreenState extends State<EditAdminsScreen> {
  String? username;
  late DocumentSnapshot user;

  final _chooseAdminFormKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  final _editAdminFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<bool> _getData() async {
    user = await FirebaseFirestore.instance.collection('admins').doc(username).get();
    return user.exists;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(EditAdminsScreen.label),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Form(
                  key: _chooseAdminFormKey,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'এডমিন ইউজারনেম',
                            hintText: 'যে এডমিনের তথ্য পরিবর্তন করতে চান, তার ইউজারনেম',
                          ),
                          validator: (value) {
                            value = value?.trim();
                            if (value == null || value.isEmpty) {
                              return 'এডমিন ইউজারনেম লিখেননি';
                            }
                            _usernameController.text = value;
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 16.0,
                      ),
                      ElevatedButton(
                        child: const Text('ফর্ম দেখুন'),
                        onPressed: () {
                          if (!_chooseAdminFormKey.currentState!.validate()) {
                            return;
                          }
                          setState(() {
                            username = _usernameController.text;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 32.0,
                ),
                if (username != null)
                  FutureBuilder(
                    future: _getData(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text(
                          'কিছু একটা সমস্যা হয়েছে। এ্যাপ বন্ধ করে ইন্টারনেট সংযোগ চেক করে আবার চালু করুন।',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                        if (snapshot.data == false) {
                          return const Text(
                            'এই ইউজারনেমের কোনো এডমিন নেই।',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }

                        _nameController.text = user.get('name');
                        return Form(
                          key: _editAdminFormKey,
                          child: Column(
                            children: [
                              Text('নিচের ফর্ম যে এডমিনের জন্য, তার ইউজারনেম $username ।'),
                              Text('বর্তমান নামঃ ${user.get('name')} ।'),
                              const Text('পাসওয়ার্ড বদলাতে না চাইলে, পাসওয়ার্ডের ঘর খালি রাখুন।'),
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'নাম',
                                ),
                                validator: (value) {
                                  value = value?.trim();
                                  if (value == null || value.isEmpty) {
                                    return 'নাম লিখেননি।';
                                  }
                                  _nameController.text = value;
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _passwordController,
                                decoration: const InputDecoration(
                                  labelText: 'পাসওয়ার্ড',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return null; // Password is to be unchanged
                                  }
                                  if (value.length < 8) {
                                    return 'পাসওয়ার্ড কমপক্ষে আট ক্যারাক্টারের হবে।';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 16.0,
                              ),
                              ElevatedButton(
                                child: const Text('পরিবর্তন করুন'),
                                onPressed: () async {
                                  if (!_editAdminFormKey.currentState!.validate()) {
                                    return;
                                  }

                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return const AlertDialog(
                                        title: Text(
                                          'দয়া করে কিছুক্ষণ অপেক্ষা করুন।',
                                          textAlign: TextAlign.center,
                                        ),
                                        content: SizedBox(
                                          height: 40.0,
                                          child: GFLoader(
                                            type: GFLoaderType.circle,
                                            size: GFSize.SMALL,
                                          ),
                                        ),
                                      );
                                    },
                                  );

                                  Map<String, dynamic> newData = {};
                                  newData['name'] = _nameController.text;
                                  if (_passwordController.text.length > 7) {
                                    //A Valid Password, new
                                    newData['passwordHash'] = getSHA256Hash(_passwordController.text);
                                    newData['sessionKeys'] = [];
                                  }

                                  user.reference.update(newData).then((value) {
                                    Navigator.of(context).pop();
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                            'সফল',
                                            textAlign: TextAlign.center,
                                          ),
                                          content: const Text('তথ্য ডাটাবেসে হালনাগাদ হয়েছে।'),
                                          actions: [
                                            TextButton(
                                              child: const Text('বেশ!'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  }, onError: (error) {
                                    Navigator.of(context).pop();
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                            'ব্যর্থ',
                                            textAlign: TextAlign.center,
                                          ),
                                          content: const Text('তথ্য ডাটাবেসে হালনাগাদ হয়নি। ইন্টারনেট সংযোগ চেক করে আবার চেষ্টা করুন।'),
                                          actions: [
                                            TextButton(
                                              child: const Text('বেশ!'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }

                      return const GFLoader(
                        type: GFLoaderType.circle,
                        size: GFSize.LARGE,
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
