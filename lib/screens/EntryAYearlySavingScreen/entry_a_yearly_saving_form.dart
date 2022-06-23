import 'package:ahbabadmin/auth/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:regexpattern/regexpattern.dart';
import 'package:sanitize_html/sanitize_html.dart' show sanitizeHtml;
import 'package:shared_preferences/shared_preferences.dart';

import 'past_yearly_savings.dart';

class EntryAYearlySavingForm extends StatefulWidget {
  final String memberRegistrationNumber;
  const EntryAYearlySavingForm(this.memberRegistrationNumber, {Key? key}) : super(key: key);

  @override
  _EntryAYearlySavingFormState createState() => _EntryAYearlySavingFormState();
}

class _EntryAYearlySavingFormState extends State<EntryAYearlySavingForm> {
  final _entrySavingFormKey = GlobalKey<FormState>();
  final _yearlyDepositController = TextEditingController();
  late int _forYear, depositedAmountTillNow, amountToDepositNow, fixedYearlyAmount;
  late List<int> sessionYears;
  late DocumentSnapshot _forYearDocSnap, _currentSessionVariables, _memberDocSnap;

  Future<bool> _isFullyDepositedForYear(int year) async {
    fixedYearlyAmount = int.parse(_currentSessionVariables.get('yearlyDeposit').toString());
    _forYearDocSnap = await _memberDocSnap.reference.collection('savings').doc(year.toString()).get();
    if (_forYearDocSnap.exists) {
      depositedAmountTillNow = int.parse(_forYearDocSnap.get('yearlyDeposit').toString());
    } else {
      depositedAmountTillNow = 0;
    }

    if (fixedYearlyAmount > depositedAmountTillNow) {
      return false;
    }
    return true;
  }

  Future<bool> _getData() async {
    _currentSessionVariables = await FirebaseFirestore.instance.collection('ahbabVariables').doc('currentSession').get();
    _memberDocSnap = await FirebaseFirestore.instance.collection('members').doc(widget.memberRegistrationNumber).get();
    int startYear = int.parse(_currentSessionVariables.get('startYear').toString());
    int endYear = int.parse(_currentSessionVariables.get('endYear').toString());
    sessionYears = [for (int i = startYear; i <= endYear; i++) i];
    int currentYear = DateTime.now().year;
    int currentMonth = DateTime.now().month;
    if (!sessionYears.contains(currentYear)) {
      return false;
    }

    if ((await _isFullyDepositedForYear(currentYear)) || currentMonth > 3) {
      currentYear++;
    } else {
      _forYear = currentYear;
      return true;
    }

    //For Next Years
    while (sessionYears.contains(currentYear)) {
      if ((await _isFullyDepositedForYear(currentYear))) {
        currentYear++;
      } else {
        _forYear = currentYear;
        return true;
      }
    }
    return false;
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!_memberDocSnap.exists)
                    const Text('এই রেজিস্ট্রেশন নম্বরের কোনো সদস্য নেই।')
                  else if (_memberDocSnap.get('isActivated') == 'false')
                    const Text('এই রেজিস্ট্রেশন নম্বরের সদস্য এখন ডি-এ্যাক্টিভ্যাটেড।')
                  else if (snapshot.data == false)
                    const Text('এই সদস্যের আর কোনো বার্ষিক সঞ্চয় জমা দিতে হবে না, অর্থাৎ জমা দেওয়া শেষ। অথবা, জমা দেওয়ার সময় শেষ।')
                  else
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'নিচের ফর্মটি সদস্য ' +
                              _memberDocSnap.get('nameInEnglishLetters') +
                              ' (রেজিস্ট্রেশন নম্বর ' +
                              _memberDocSnap.reference.id +
                              ')-এর ' +
                              _forYear.toString() +
                              ' সালের বার্ষিক সঞ্চয়ের জন্য।',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'এই সেশনের ধার্য্যকৃত বার্ষিক সঞ্চয়ঃ ',
                            style: const TextStyle(
                              fontFamily: 'SolaimanLipi',
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                            children: [
                              TextSpan(
                                text: fixedYearlyAmount.toString(),
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const TextSpan(
                                text: '\nএই সদস্য এই বছরের জন্য এখন পর্যন্ত জমা দিয়েছেনঃ ',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: depositedAmountTillNow.toString(),
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const TextSpan(
                                text: '\nএই বছরে উনি আরো জমা দিতে হবেঃ ',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: (fixedYearlyAmount - depositedAmountTillNow).toString(),
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Form(
                          key: _entrySavingFormKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextFormField(
                                controller: _yearlyDepositController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'এখন কত জমা নিচ্ছেন?',
                                ),
                                validator: (value) {
                                  value = value?.trim();
                                  if (value == null || value.isEmpty) {
                                    return 'এখন কত জমা নিচ্ছেন, তা লিখেননি।';
                                  }
                                  _yearlyDepositController.text = value;
                                  if (!value.isNumeric()) {
                                    return 'এই ঘরে শুধু ইংরেজি ডিজিট থাকবে।';
                                  }
                                  amountToDepositNow = int.parse(value);
                                  if (depositedAmountTillNow + amountToDepositNow > fixedYearlyAmount) {
                                    return 'নির্ধারিত বার্ষিক সঞ্চয়ের চেয়ে বেশি হয়ে যাচ্ছে।';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 16.0,
                              ),
                              ElevatedButton(
                                child: const Text('জমা গ্রহণ করলাম'),
                                onPressed: () async {
                                  bool proceed = true;
                                  if (_entrySavingFormKey.currentState!.validate()) {
                                    await showDialog<void>(
                                      context: context,
                                      barrierDismissible: false, // user must tap button!
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('ভালো করে দেখে নিন!'),
                                          content: SingleChildScrollView(
                                            child: ListBody(
                                              children: [
                                                Text('সদস্য নম্বরঃ ' + _memberDocSnap.reference.id),
                                                Text('নামঃ ' + _memberDocSnap.get('nameInEnglishLetters')),
                                                Text('যে সালের জন্য বার্ষিক সঞ্চয়ঃ ' + _forYear.toString()),
                                                Text('এখন জমা নিচ্ছেনঃ ' + amountToDepositNow.toString()),
                                                Text('বাকি রইলোঃ ' + (fixedYearlyAmount - depositedAmountTillNow - amountToDepositNow).toString()),
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

                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    String loginStatus = await checkSessionKey();
                                    if (loginStatus != '') {
                                      await prefs.clear();
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pushReplacementNamed('LogInScreen');
                                      return;
                                    }
                                    List<String> addAndModificationDetails = [];
                                    String depositTimestamp = DateTime.now().toString();
                                    if (_forYearDocSnap.exists) {
                                      addAndModificationDetails =
                                          (_forYearDocSnap.get('addAndModificationDetails') as List).map((e) => e.toString()).toList();
                                      depositTimestamp = _forYearDocSnap.get('depositTimestamp').toString();
                                    }

                                    addAndModificationDetails.add('Added ' +
                                        sanitizeHtml(amountToDepositNow.toString()) +
                                        ' by ' +
                                        prefs.getString('name')! +
                                        ' (' +
                                        prefs.getString('username')! +
                                        ') on ' +
                                        DateTime.now().toString());

                                    _forYearDocSnap.reference.set({
                                      'yearlyDeposit': (depositedAmountTillNow + amountToDepositNow).toString(),
                                      'depositTimestamp': depositTimestamp,
                                      'addAndModificationDetails': addAndModificationDetails,
                                    }).then((value) {
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
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  if(_memberDocSnap.exists) PastYearlySavings(_memberDocSnap),
                ],
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
