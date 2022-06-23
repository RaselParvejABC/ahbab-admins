
import 'package:getwidget/getwidget.dart';

import '../../utilities/for_json.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stream_transform/stream_transform.dart';

class PaidLoans extends StatefulWidget {
  const PaidLoans({Key? key}) : super(key: key);

  @override
  State<PaidLoans> createState() => _PaidLoansState();
}

class _PaidLoansState extends State<PaidLoans> {
  final Stream<QuerySnapshot<Map<String, dynamic>>> loanApplicationsSnapshot = FirebaseFirestore.instance.collection('loanApplications')
      .where('status', isEqualTo: 'paid')
      .orderBy('paidBackTimestamp')
      .snapshots();
  final Stream<QuerySnapshot<Map<String, dynamic>>> membersSnapshot = FirebaseFirestore.instance.collection('members')
      .snapshots();

  List<DocumentSnapshot<Map<String, dynamic>>> members = [];
  List<DocumentSnapshot<Map<String, dynamic>>> loanApplications = [];

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: loanApplicationsSnapshot.combineLatestAll([membersSnapshot]),
      builder: (context, snapshot){

        if(snapshot.hasError){
          return const Text('কিছু একটা সমস্যা হয়েছে। পরে চেষ্টা করুন।');
        }

        if(snapshot.hasData){
          List<QuerySnapshot<Map<String, dynamic>>>  snapshots = (snapshot.data as List).map((e) => e as QuerySnapshot<Map<String, dynamic>>).toList();
          loanApplications = snapshots.first.docs;
          members = snapshots.last.docs;

          if(loanApplications.isEmpty){
            return const Text('এই মুহুর্তে কোনো পরিশোধিত ঋণ নেই।');
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'পরিশোধিত ঋণসমূহ',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                const Text(
                  'সর্বশেষ যে ঋণ পরিশোধ হয়েছে, সেটি আগে আছে।',
                  style: TextStyle(
                    fontSize: 12.0,
                  ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                ... loanApplications.map((application) => getLoanWidget(application, context)).toList(),
              ],
            ),
          );
        }

        return const GFLoader();
      },
    );
  }



  Widget getLoanWidget(DocumentSnapshot<Map<String, dynamic>> application, BuildContext context) {
    String title = 'ঋণপ্রার্থীর সদস্য নম্বরঃ ' + application.get('applicantMemberID');
    String details = 'ঋণের পরিমাণঃ ' + application.get('loanAmount').toString();
    details += '\nপণ্যের বর্ণনাঃ ' + application.get('productDetails').toString();
    details += '\nলোনের মেয়াদঃ ' + application.get('loanPeriodInMonth').toString() + ' মাস';
    details += '\nনিতে চাচ্ছেন ' + application.get('expectedTakeOutMonth').toString() + ' মাসে';
    List<String> bailsmen =  getListFromJSONArray(application.get('bailsmenMemberIDs'));
    DocumentSnapshot bailsmanOne = members.firstWhere((element) => element.reference.id == bailsmen.first);
    DocumentSnapshot bailsmanTwo = members.firstWhere((element) => element.reference.id == bailsmen.last);
    details += '\nপ্রথম জামিনদারঃ ' + bailsmanOne.get('nameInBanglaLetters').toString();
    details += ' (সদস্য নম্বর ' + bailsmanOne.reference.id + ', ';
    details += ' ফোন নাম্বার ' + bailsmanOne.get('phoneNumbers').toString() + ')';
    details += '\nদ্বিতীয় জামিনদারঃ ' + bailsmanTwo.get('nameInBanglaLetters').toString();
    details += ' (সদস্য নম্বর ' + bailsmanTwo.reference.id + ', ';
    details += ' ফোন নাম্বার ' + bailsmanTwo.get('phoneNumbers').toString() + ')';
    details += '\nনিয়েছেন ' + application.get('takeOutTimestamp').toString() + ' তারিখে';
    details += '\nপরিশোধ করবেন ' + application.get('paybackAmount').toString();
    details += '\nপরিশোধ করবেন ' + application.get('dueTimestamp').toString() + ' তারিখে';
    DateTime paidBackTimestamp = DateTime.fromMillisecondsSinceEpoch(int.tryParse(application.get('paidBackTimestamp').toString())!);
    details += '\nপরিশোধ করেছেন Y${paidBackTimestamp.year} M${paidBackTimestamp.month} D${paidBackTimestamp.day} তারিখে';
    details += "\n* " + getListFromJSONArray(application.get('timeline')).reversed.join('\n* ');

    return GFAccordion(
      title: title,
      contentChild: Text(
        details,
      ),
    );
  }

}