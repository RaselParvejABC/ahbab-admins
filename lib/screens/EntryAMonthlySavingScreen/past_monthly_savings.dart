import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:getwidget/getwidget.dart';

class PastMonthlySavings extends StatelessWidget {
  final DocumentSnapshot memberDocSnap;
  const PastMonthlySavings(this.memberDocSnap, {Key? key}) : super(key: key);

  final List<String> namesOfMonths = const [
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
  ];

  Stream<List<Map<String, dynamic>>> _monthsSnapshotForYear(int year) {
    return memberDocSnap.reference.collection('savings/' + year.toString() + '/months').snapshots().map((event) {
      return event.docs.map((e) {
        Map<String, dynamic> map = Map.from(e.data());
        map['year'] = year.toString();
        map['month'] = e.reference.id;
        return map;
      }).toList();
    }).startWith([]);
  }

  Stream<List<Map<String, dynamic>>> _getStream() {
    return FirebaseFirestore.instance.collection('ahbabVariables').doc('currentSession').snapshots().map((event) {
      //print('Current Session');
      int startYear = int.parse(event.get('startYear').toString());
      int endYear = int.parse(event.get('endYear').toString());
      List<int> sessionYears = [for (int i = startYear; i <= endYear; i++) i];
      var firstStream = _monthsSnapshotForYear(sessionYears.first);
      sessionYears.remove(sessionYears.first);
      return firstStream.combineLatestAll(sessionYears.map((e) => _monthsSnapshotForYear(e))).map((event) {
        //print('Combine ' + event.length.toString());
        // for(int i=0; i< event.length; i++){
        //   print(i.toString() + ' ' + event[i].length.toString());
        // }
        return event.reduce((value, element) => value + element);
      });
    }).switchLatest();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        StreamBuilder(
            stream: _getStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('কিছু একটা সমস্যা হয়েছে। এ্যাপ বন্ধ করে আবার চালু করুন।');
              }
              if (snapshot.hasData) {
                var months = (snapshot.data as List).map((e) => e as Map<String, dynamic>).toList();
                months.sort((a, b) {
                  if (a['year'].toString() != b['year'].toString()) {
                    return int.parse(b['year'].toString()) - int.parse(a['year'].toString());
                  }
                  return namesOfMonths.indexOf(b['month'].toString()) - namesOfMonths.indexOf(a['month'].toString());
                });
                return Column(
                  children: [
                    if(months.isNotEmpty) const Text(
                      'বিগত মাসিক সঞ্চয়সমূহ',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    if(months.isNotEmpty) for (int i = 0; i < months.length; i++) _getMonthCard(months[i]),
                  ],
                );
              }
              return const GFLoader(
                type: GFLoaderType.circle,
              );
            }),
      ],
    );
  }

  _getMonthCard(Map<String, dynamic> month) {
    List<String> addAndModificationDetails = (month['addAndModificationDetails'] as List).map((e) => e as String).toList();
    return DefaultTextStyle(
      style: const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontFamily: 'SolaimanLipi',
      ),
      child: GFListTile(
        padding: const EdgeInsets.all(8.0),
        color: Colors.black.withOpacity(0.7),
        title: Text(
          month['month'].toString() + ' ' + month['year'].toString(),
          style: const TextStyle(
            fontSize: 20.0,
          ),
        ),
        description: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'মাসিক সঞ্চয়ঃ ' + month['monthlyDeposit'].toString(),
            ),
            Text(
              'মাসিক প্রশাসনিক ব্যয়বাবদ ফিঃ ' + month['monthlyFeeForAdministrativeExpense'].toString(),
            ),
            GFAccordion(
              collapsedTitleBackgroundColor: Colors.blueAccent.withOpacity(0.2),
              expandedTitleBackgroundColor: Colors.blueAccent.withOpacity(0.2),
              contentBackgroundColor: Colors.black.withOpacity(0.7),
              titleChild: const Text(
                'টাইমলাইন',
                style: TextStyle(
                  fontSize: 13.0,
                ),
              ),
              contentChild: Column(
                children: [
                  ...[for(int i = 0; i< addAndModificationDetails.length; i++)
                    Text(
                      addAndModificationDetails[i] + '\n',
                      style: const TextStyle(
                        fontSize: 10.0,
                      ),
                    )
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
