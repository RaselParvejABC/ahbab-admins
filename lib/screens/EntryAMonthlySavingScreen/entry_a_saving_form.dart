import 'package:ahbabadmin/auth/auth.dart';
import 'past_monthly_savings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EntryASavingForm extends StatefulWidget {
  final String memberRegistrationNumber;
  const EntryASavingForm(this.memberRegistrationNumber, {Key? key}) : super(key: key);

  @override
  _EntryASavingFormState createState() => _EntryASavingFormState();
}

class _EntryASavingFormState extends State<EntryASavingForm> {
  late DocumentSnapshot memberDocSnap, currentSessionVariables;
  late List<int> sessionYears;
  late String _forYear;
  late String _forMonth;

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

  Future<bool> _isDepositedForYearMonthInteger(int yearMonthInteger) async {
    String year = (yearMonthInteger ~/ 12).toString();
    String month = _getMonthName(yearMonthInteger % 12 + 1);
    DocumentSnapshot docSnap =
        await FirebaseFirestore.instance.collection('members/' + widget.memberRegistrationNumber + '/savings/' + year + '/months/').doc(month).get();
    return docSnap.exists;
  }

  Future<bool> _getData() async {
    memberDocSnap = await FirebaseFirestore.instance.collection('members').doc(widget.memberRegistrationNumber).get();
    currentSessionVariables = await FirebaseFirestore.instance.collection('ahbabVariables').doc('currentSession').get();
    int startYear = int.parse(currentSessionVariables.get('startYear').toString());
    int endYear = int.parse(currentSessionVariables.get('endYear').toString());
    sessionYears = [for (int i = startYear; i <= endYear; i++) i];
    if (!sessionYears.contains(DateTime.now().year)) {
      return false; //Member cannot/don't have to pay
    }
    int currentYearMonthInteger = DateTime.now().year * 12 + DateTime.now().month - 1;
    int lastMonthInteger = currentYearMonthInteger - 1;
    int forYearMonthInteger = currentYearMonthInteger;
    if (sessionYears.contains(lastMonthInteger ~/ 12) && !(await _isDepositedForYearMonthInteger(lastMonthInteger))) {
      forYearMonthInteger = lastMonthInteger;
    }
    while (await _isDepositedForYearMonthInteger(forYearMonthInteger)) {
      forYearMonthInteger++;
    }

    if (!sessionYears.contains(forYearMonthInteger ~/ 12)) {
      return false; //Member cannot/don't have to pay
    }

    _forYear = (forYearMonthInteger ~/ 12).toString();
    _forMonth = _getMonthName(forYearMonthInteger % 12 + 1);
    return true; //Member can/must pay
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
                  if (!memberDocSnap.exists)
                    const Text('এই রেজিস্ট্রেশন নম্বরের কোনো সদস্য নেই।')
                  else if (memberDocSnap.get('isActivated') == 'false')
                    const Text('এই রেজিস্ট্রেশন নম্বরের সদস্য এখন ডি-এ্যাক্টিভ্যাটেড।')
                  else if (snapshot.data == false)
                    const Text('এই সদস্যের আর কোনো মাসিক সঞ্চয় জমা দিতে হবে না, অর্থাৎ জমা দেওয়া শেষ। অথবা, জমা দেওয়ার সময় শেষ।')
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
                        Text(
                          'এই মাসিক সঞ্চয়টি ' + _forYear + ' সালের ' + _forMonth + ' মাসের জন্য।',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        ElevatedButton(
                          child: const Text('জমা গ্রহণ করলাম'),
                          onPressed: () async {
                            bool proceed = true;
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
                                        Text('মাসিক সঞ্চয় বাবদঃ ' + memberDocSnap.get('monthlyFixedAmount')!.toString()),
                                        Text('মাসিক প্রশাসনিক ব্যয়বাবদ ফিঃ ' +
                                            currentSessionVariables.get('monthlyFeeForAdministrativeExpense').toString()),
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
                            DocumentSnapshot savingOfMonth =
                                await memberDocSnap.reference.collection('savings').doc(_forYear).collection('months').doc(_forMonth).get();
                            if (savingOfMonth.exists) {
                              Navigator.of(context).pop();
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('ভুল করছেন।'),
                                    content: const Text(
                                      'এই মাসের সঞ্চয় এরই মাঝে জমা হয়ে গিয়েছে।',
                                      textAlign: TextAlign.center,
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text('বেশ!'),
                                        onPressed: () {
                                          setState(() {});
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                              return;
                            }
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            String loginStatus = await checkSessionKey();
                            if (loginStatus != '') {
                              await prefs.clear();
                              Navigator.of(context).pushReplacementNamed('LogInScreen');
                              return;
                            }

                            savingOfMonth.reference.set({
                              'monthlyDeposit': memberDocSnap.get('monthlyFixedAmount'),
                              'monthlyFeeForAdministrativeExpense': currentSessionVariables.get('monthlyFeeForAdministrativeExpense').toString(),
                              'depositTimestamp': DateTime.now().toString(),
                              'addAndModificationDetails': [
                                'Added by ' + prefs.getString('name')! + ' (' + prefs.getString('username')! + ') on ' + DateTime.now().toString(),
                              ]
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
                          },
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                      ],
                    ),
                  if(memberDocSnap.exists) PastMonthlySavings(memberDocSnap),
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
