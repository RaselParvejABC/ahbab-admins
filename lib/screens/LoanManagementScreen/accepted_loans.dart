import 'package:ahbabadmin/dialogs/wait_dialog.dart';
import 'package:ahbabadmin/screens/LoanManagementScreen/loan_edit_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../dialogs/confirmation_dialog.dart';
import '../../dialogs/inform_dialog.dart';
import 'package:getwidget/getwidget.dart';

import '../../utilities/for_json.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stream_transform/stream_transform.dart';

class AcceptedLoans extends StatefulWidget {
  const AcceptedLoans({Key? key}) : super(key: key);

  @override
  State<AcceptedLoans> createState() => _AcceptedLoansState();
}

class _AcceptedLoansState extends State<AcceptedLoans> {
  final Stream<QuerySnapshot<Map<String, dynamic>>> loanApplicationsSnapshot = FirebaseFirestore.instance.collection('loanApplications')
      .where('status', isEqualTo: 'accepted')
      .orderBy('dueTimestamp')
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
            return const Text('এই মুহুর্তে কোনো চলমান ঋণ নেই।');
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'চলমান ঋণসমূহ',
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
                  'যে ঋণের পরিশোধের তারিখ আগে, সেটি আগে আছে।',
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
    details += "\n* " + getListFromJSONArray(application.get('timeline')).reversed.join('\n* ');

    return GFAccordion(
      title: title,
      contentChild: Column(
        children: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
            ),
            child: const Text('ঋণের তথ্য ডিলিট করুন'),
            onPressed: () async {
              bool response =  await showConfirmationDialog(context, 'নিশ্চিত তো?', 'এই ঋণটির তথ্য ডিলিট করতে যাচ্ছেন।');
              if(response){
                application.reference.delete().then((value) async {
                  await showInformDialog(context, 'সফল', 'ঋণের তথ্য ডিলিট হয়েছে।');
                }, onError: (error) async{
                  await showInformDialog(context, 'ব্যর্থ', 'ঋণের তথ্য ডিলিট হয়নি। ইন্টারনেট সংযোগ চেক করে পরে চেষ্টা করুন।');
                });
              }
            },
          ),
          Text(
            details,
          ),
          const SizedBox(
            height: 16.0,
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            ),
            child: const Text('ঋণের তথ্য এডিট করুন'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoanEditScreen(application),
                ),
              );
            },
          ),
          const SizedBox(
            height: 16.0,
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            ),
            child: const Text('ঋণটি পরিশোধ হয়েছে'),
            onPressed: () async{
              showWaitDialog(context);
              List<String> timeline = [];
              try{
                timeline = getListFromJSONArray(application.get('timeline'));
              } catch (error){
                1;
              }
              SharedPreferences prefs = await SharedPreferences.getInstance();
              DateTime currentDate = DateTime.now();
              String timelineComment = "${currentDate.year} ${currentDate.month} ${currentDate.day} ";
              timelineComment += "${prefs.getString('username')} (${prefs.getString('name')}) : ";
              timelineComment += "Marked as PAID.";

              timeline.add(timelineComment);

              application.reference.update({
                'status' : 'paid',
                'timeline' : timeline,
                'paidBackTimestamp' : currentDate.millisecondsSinceEpoch,
              }).then((value) async {
                Navigator.of(context).pop();
                await showInformDialog(context, 'সফল', 'তথ্য হালনাগাদ হয়েছে।');
              }, onError: (error) async{
                Navigator.of(context).pop();
                await showInformDialog(context, 'ব্যর্থ', 'তথ্য হালনাগাদ হয়নি। ইন্টারনেট সংযোগ চেক করে পরে চেষ্টা করুন।');
              });
            },
          ),
        ],
      ),
    );
  }

}
