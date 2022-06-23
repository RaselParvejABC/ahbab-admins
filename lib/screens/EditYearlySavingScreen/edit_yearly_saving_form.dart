import '../EntryAYearlySavingScreen/past_yearly_savings.dart';

import '../../auth/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:regexpattern/regexpattern.dart';

class EditYearlySavingForm extends StatefulWidget {
  final String memberRegistrationNumber;
  const EditYearlySavingForm(this.memberRegistrationNumber, {Key? key}) : super(key: key);

  @override
  _EditYearlySavingFormState createState() => _EditYearlySavingFormState();
}

class _EditYearlySavingFormState extends State<EditYearlySavingForm> {
  late DocumentSnapshot memberDocSnap, currentSessionVariables;
  late List<int> sessionYears;
  late String _forYear;
  late SharedPreferences prefs;
  TextEditingController newBalanceController = TextEditingController();
  final _editYearlySavingFormKey = GlobalKey<FormState>();

  Future<bool> _getData() async {
    memberDocSnap = await FirebaseFirestore.instance.collection('members').doc(widget.memberRegistrationNumber).get();
    currentSessionVariables = await FirebaseFirestore.instance.collection('ahbabVariables').doc('currentSession').get();
    int startYear = int.parse(currentSessionVariables.get('startYear').toString());
    int endYear = int.parse(currentSessionVariables.get('endYear').toString());
    sessionYears = [for (int i = startYear; i <= endYear; i++) i];
    prefs = await SharedPreferences.getInstance();
    _forYear = sessionYears.first.toString();
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
                key: _editYearlySavingFormKey,
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
                            'বার্ষিক সঞ্চয়ের ধার্য্যকৃত পরিমাণ ' + currentSessionVariables.get('yearlyDeposit').toString(),
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
                                    hintText: 'যে বছরের বার্ষিক জমা সম্পাদনা করবেন',
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
                            ],
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          TextFormField(
                            controller: newBalanceController,
                            decoration: const InputDecoration(
                              labelText: 'এই সালের বার্ষিক সঞ্চয়ের জমার পরিমাণ কততে নিতে চান?',
                            ),
                            validator: (value) {
                              value = value?.trim();
                              if (value == null || value.isEmpty) {
                                return 'এই সালের বার্ষিক সঞ্চয়ের জমার পরিমাণ কততে নিতে চান, তা লিখেননি।';
                              }
                              newBalanceController.text = value;
                              if (!value.isNumeric()) {
                                return 'এই ঘরে শুধু ইংরেজি ডিজিট থাকবে।';
                              }
                              if (int.parse(value) > int.parse(currentSessionVariables.get('yearlyDeposit').toString())) {
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

                              if(!_editYearlySavingFormKey.currentState!.validate()){
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
                                          Text('বার্ষিক সঞ্চয় বাবদঃ ' + newBalanceController.text),
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

                              DocumentSnapshot savingOfYear =
                              await memberDocSnap.reference.collection('savings').doc(_forYear).get();

                              Map<String, dynamic> savingOfYearData = {};

                              if(savingOfYear.exists){
                                savingOfYearData = savingOfYear.data() as Map<String, dynamic>;
                              }

                              savingOfYearData['yearlyDeposit'] = newBalanceController.text;

                              if (!savingOfYear.exists) {
                                savingOfYearData['depositTimestamp'] = DateTime.now().toString();
                              }

                              List<String> addAndModificationDetails = [];

                              if (savingOfYear.exists) {
                                addAndModificationDetails.addAll((savingOfYear.get('addAndModificationDetails') as List).map((e) => e.toString()));
                              }

                              addAndModificationDetails.add(
                                  'Edited to Yearly Deposit ' +
                                      newBalanceController.text +
                                      ' by ' +
                                      prefs.getString('name')! +
                                      ' (' +
                                      prefs.getString('username')! +
                                      ') on ' +
                                      DateTime.now().toString()
                              );

                              savingOfYearData['addAndModificationDetails'] = addAndModificationDetails;

                              savingOfYear.reference.set(
                                savingOfYearData
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
                    if (memberDocSnap.exists) PastYearlySavings(memberDocSnap),
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
