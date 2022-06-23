import '../EntryAMonthlySavingScreen/past_monthly_savings.dart';

import '../../auth/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:regexpattern/regexpattern.dart';

class EditMonthlySavingForm extends StatefulWidget {
  final String memberRegistrationNumber;
  const EditMonthlySavingForm(this.memberRegistrationNumber, {Key? key}) : super(key: key);

  @override
  _EditMonthlySavingFormState createState() => _EditMonthlySavingFormState();
}

class _EditMonthlySavingFormState extends State<EditMonthlySavingForm> {
  late DocumentSnapshot memberDocSnap, currentSessionVariables;
  late List<int> sessionYears;
  late String _forYear;
  late String _forMonth;
  late SharedPreferences prefs;
  TextEditingController newBalanceController = TextEditingController();
  TextEditingController newAdministrativeFeeController = TextEditingController();
  final _editMonthlySavingFormKey = GlobalKey<FormState>();

  static String _getMonthName(int index) {
    return [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ].elementAt(index - 1);
  }

  Future<bool> _getData() async {
    memberDocSnap = await FirebaseFirestore.instance.collection('members').doc(widget.memberRegistrationNumber).get();
    currentSessionVariables = await FirebaseFirestore.instance.collection('ahbabVariables').doc('currentSession').get();
    int startYear = int.parse(currentSessionVariables.get('startYear').toString());
    int endYear = int.parse(currentSessionVariables.get('endYear').toString());
    sessionYears = [for (int i = startYear; i <= endYear; i++) i];
    prefs = await SharedPreferences.getInstance();
    _forYear = sessionYears.first.toString();
    _forMonth = _getMonthName(1);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getData(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('কিছু একটা সমস্যা হয়েছে। এ্যাপটি বন্ধ করে চালু করুন।');
        }

        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return Container(
            margin: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _editMonthlySavingFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!memberDocSnap.exists)
                      const Text('এই রেজিস্ট্রেশন নম্বরের কোনো সদস্য নেই।')
                    else if (memberDocSnap.get('isActivated') == 'false')
                      const Text('এই রেজিস্ট্রেশন নম্বরের সদস্য এখন ডি-এ্যাক্টিভ্যাটেড।')
                    else
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'নিচের ফর্মটি সদস্য ' +
                                memberDocSnap.get('nameInBanglaLetters') +
                                ' (রেজিস্ট্রেশন নম্বর ' +
                                memberDocSnap.reference.id +
                                ')-এর জন্য।',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          Text(
                            'উনার জন্য ধার্য্যকৃত মাসিক সঞ্চয়ের পরিমাণ ' + memberDocSnap.get('monthlyFixedAmount'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          Text(
                            'মাসিক প্রশাসনিক ব্যয়বাবদ ফি ' + currentSessionVariables.get('monthlyFeeForAdministrativeExpense').toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'কোন বছরের?',
                                    hintText: 'যে বছরের মাসিক জমা সম্পাদনা করবেন',
                                  ),
                                  items: [
                                    for (int i = 0; i < sessionYears.length; i++)
                                      DropdownMenuItem(
                                        value: sessionYears.elementAt(i).toString(),
                                        child: Text(sessionYears.elementAt(i).toString()),
                                      ),
                                  ],
                                  onChanged: (value) {
                                    _forYear = value.toString();
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 16.0,
                              ),
                              Expanded(
                                child: DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'কোন মাসের?',
                                    hintText: 'যে মাসের মাসিক জমা সম্পাদনা করবেন',
                                  ),
                                  items: [
                                    for (int i = 1; i < 13; i++)
                                      DropdownMenuItem(
                                        value: _getMonthName(i),
                                        child: Text(_getMonthName(i)),
                                      ),
                                  ],
                                  onChanged: (value) {
                                    _forMonth = value.toString();
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          TextFormField(
                            controller: newBalanceController,
                            decoration: const InputDecoration(
                              labelText: 'ওপরে বাছাই করা মাসের মাসিক সঞ্চয়ের জমার পরিমাণ কততে নিতে চান?',
                            ),
                            validator: (value) {
                              value = value?.trim();
                              if (value == null || value.isEmpty) {
                                return 'এই মাসের মাসিক সঞ্চয়ের জমার পরিমাণ কততে নিতে চান, তা লিখেননি।';
                              }
                              newBalanceController.text = value;
                              if (!value.isNumeric()) {
                                return 'এই ঘরে শুধু ইংরেজি ডিজিট থাকবে।';
                              }
                              if (int.parse(value) > int.parse(memberDocSnap.get('monthlyFixedAmount')!.toString())) {
                                return 'ধার্য্যকৃত পরিমাণের চেয়ে বেশি হয়ে যাচ্ছে।';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          TextFormField(
                            controller: newAdministrativeFeeController,
                            decoration: const InputDecoration(
                              labelText: 'ওপরে বাছাই করা মাসের মাসিক প্রশাসনিক ব্যয়বাবদ ফির জমার পরিমাণ কততে নিতে চান?',
                            ),
                            validator: (value) {
                              value = value?.trim();
                              if (value == null || value.isEmpty) {
                                return 'ওপরে বাছাই করা মাসের মাসিক প্রশাসনিক ব্যয়বাবদ ফির জমার পরিমাণ কততে নিতে চান, তা লিখেননি।';
                              }
                              newAdministrativeFeeController.text = value;
                              if (!value.isNumeric()) {
                                return 'এই ঘরে শুধু ইংরেজি ডিজিট থাকবে।';
                              }
                              if (int.parse(value) > int.parse(currentSessionVariables.get('monthlyFeeForAdministrativeExpense').toString())) {
                                return 'ধার্য্যকৃত পরিমাণের চেয়ে বেশি হয়ে যাচ্ছে।';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          ElevatedButton(
                            child: const Text('ডাটাবেসে সেভ করুন।'),
                            onPressed: () async {
                              bool proceed = true;

                              if(!_editMonthlySavingFormKey.currentState!.validate()){
                                proceed = false;
                              }
                              if(!proceed){
                                return;
                              }

                              await showDialog<void>(
                                context: context,
                                barrierDismissible: false, // user must tap button!
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('ভালো করে দেখে নিন!'),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: [
                                          Text('সদস্য নম্বরঃ ' + memberDocSnap.reference.id),
                                          Text('নামঃ ' + memberDocSnap.get('nameInBanglaLetters')),
                                          Text('যে সালের জন্য সঞ্চয়ঃ ' + _forYear),
                                          Text('যে মাসের জন্য সঞ্চয়ঃ ' + _forMonth),
                                          Text('মাসিক সঞ্চয় বাবদঃ ' + newBalanceController.text),
                                          Text('মাসিক প্রশাসনিক ব্যয়বাবদ ফিঃ ' + newAdministrativeFeeController.text),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('না'),
                                        onPressed: () {
                                          proceed = false;
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('হ্যাঁ'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (!proceed) {
                                return;
                              }
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const AlertDialog(
                                    title: LinearProgressIndicator(
                                      value: null,
                                    ),
                                    content: Text(
                                      'কিছুক্ষণ অপেক্ষা করুন।',
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                },
                              );

                              String loginStatus = await checkSessionKey();
                              if (loginStatus != '') {
                                await prefs.clear();
                                Navigator.of(context).pushReplacementNamed('LogInScreen');
                                return;
                              }

                              DocumentSnapshot savingOfMonth =
                              await memberDocSnap.reference.collection('savings').doc(_forYear).collection('months').doc(_forMonth).get();

                              Map<String, dynamic> savingOfMonthData = {};

                              if(savingOfMonth.exists){
                                savingOfMonthData = savingOfMonth.data() as Map<String, dynamic>;
                              }

                              savingOfMonthData['monthlyDeposit'] = newBalanceController.text;
                              savingOfMonthData['monthlyFeeForAdministrativeExpense'] = newAdministrativeFeeController.text;

                              if (!savingOfMonth.exists) {
                                savingOfMonthData['depositTimestamp'] = DateTime.now().toString();
                              }

                              List<String> addAndModificationDetails = [];

                              if (savingOfMonth.exists) {
                                addAndModificationDetails.addAll((savingOfMonth.get('addAndModificationDetails') as List).map((e) => e.toString()));
                              }

                              addAndModificationDetails.add(
                                  'Edited to Monthly Deposit ' +
                                      newBalanceController.text +
                                      ' and Monthly Fee ' +
                                      newAdministrativeFeeController.text +
                                      ' by ' +
                                      prefs.getString('name')! +
                                      ' (' +
                                      prefs.getString('username')! +
                                      ') on ' +
                                      DateTime.now().toString()
                              );

                              savingOfMonthData['addAndModificationDetails'] = addAndModificationDetails;

                              savingOfMonth.reference.set(
                                savingOfMonthData
                              ).then((value) {
                                Navigator.of(context).pop();
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('সফল'),
                                      content: const Text('ডাটাবেসে জমার তথ্য সেভ হয়েছে।'),
                                      actions: [
                                        TextButton(
                                          child: const Text('ওকে'),
                                          onPressed: () {
                                            setState(() {});
                                            Navigator.of(context).pop();
                                          },
                                        ),
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
                                      title: const Text('ব্যর্থ'),
                                      content: const Text('ডাটাবেসে জমার তথ্য সেভ হয়নি। কিছুক্ষণ পরে আবার চেষ্টা করুন।'),
                                      actions: [
                                        TextButton(
                                          child: const Text('ওকে'),
                                          onPressed: () => Navigator.of(context).pop(),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              });
                            },
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                        ],
                      ),
                    if (memberDocSnap.exists) PastMonthlySavings(memberDocSnap),
                  ],
                ),
              ),
            ),
          );
        }

        return const Align(
          alignment: Alignment.topCenter,
          child: CircularProgressIndicator(
            value: null,
          ),
        );
      },
    );
  }
}
