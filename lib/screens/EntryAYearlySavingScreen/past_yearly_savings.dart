import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:getwidget/getwidget.dart';

class PastYearlySavings extends StatelessWidget {
  final DocumentSnapshot memberDocSnap;
  const PastYearlySavings(this.memberDocSnap, {Key? key}) : super(key: key);

  Stream<Map<String, dynamic>> _snapshotForYear(int year) {
    return memberDocSnap.reference.collection('savings').doc(year.toString()).snapshots().map((event) {
      Map<String, dynamic> map = Map.from(event.data() ?? {});
      if (map.isNotEmpty) {
        map['year'] = event.reference.id;
      }

      return map;
    });
  }

  Stream<List<Map<String, dynamic>>> _getStream() {
    return FirebaseFirestore.instance.collection('ahbabVariables').doc('currentSession').snapshots().map((event) {
      //print('Current Session');
      int startYear = int.parse(event.get('startYear').toString());
      int endYear = int.parse(event.get('endYear').toString());
      List<int> sessionYears = [for (int i = startYear; i <= endYear; i++) i];
      var firstStream = _snapshotForYear(sessionYears.first);
      sessionYears.remove(sessionYears.first);
      return firstStream.combineLatestAll(sessionYears.map((e) => _snapshotForYear(e)));
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
                var years = (snapshot.data as List).map((e) => e as Map<String, dynamic>).toList().where((element) => element.isNotEmpty).toList();
                years.sort((a, b) {
                  return int.parse(b['year'].toString()) - int.parse(a['year'].toString());
                });
                return Column(
                  children: [
                    if(years.isNotEmpty) const Text(
                      'বিগত বার্ষিক সঞ্চয়সমূহ',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if(years.isNotEmpty) for (int i = 0; i < years.length; i++) _getYearCard(years[i]),
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

  _getYearCard(Map<String, dynamic> year) {
    List<String> addAndModificationDetails = (year['addAndModificationDetails'] as List).map((e) => e as String).toList();
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
          year['year'].toString(),
          style: const TextStyle(
            fontSize: 20.0,
          ),
        ),
        description: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'বার্ষিক সঞ্চয়ঃ ' + year['yearlyDeposit'].toString(),
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
                  ...[
                    for (int i = 0; i < addAndModificationDetails.length; i++)
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
