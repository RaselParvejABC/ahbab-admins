import 'package:ahbabadmin/screens/EditCommitteeScreen/committee_members.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/getwidget.dart';
import 'package:provider/provider.dart';

import 'add_new_committee_member.dart';
import 'committee_members_table.dart';

class EditCommitteeScreen extends StatefulWidget {
  static String get label => "কমিটি এডিট";
  static String get requiredAdminPrivilege => "committee-edit";
  static String get routeName => "EditCommitteeScreen";
  const EditCommitteeScreen({Key? key}) : super(key: key);

  @override
  _EditCommitteeScreenState createState() => _EditCommitteeScreenState();
}

class _EditCommitteeScreenState extends State<EditCommitteeScreen> {


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CommitteeMembers()),
      ],
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(EditCommitteeScreen.label),
          ),
          body: Padding(
            padding: const EdgeInsets.all(32.0),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('ahbabVariables').doc('committee').snapshots(),
              builder: (context, snapshot) {
                if(snapshot.hasError){
                  return const Text('কিছু একটা সমস্যা হয়েছে। এ্যাপ বন্ধ করে ইন্টারনেট সংযোগ চেক করে আবার চেষ্টা করুন।');
                }
                if(snapshot.hasData){

                  if((snapshot.data as DocumentSnapshot).exists){
                    List<Map<String, dynamic>> fromServer = ((snapshot.data as DocumentSnapshot)['members'] as List).map((e) => e as Map<String, dynamic>).toList();
                    var committeeMembers = context.read<CommitteeMembers>();
                    committeeMembers.deleteAll();
                    for(Map<String, dynamic> element in fromServer){
                      committeeMembers.add(element);
                    }
                  }
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        AddNewCommitteeMember(),
                        const SizedBox(
                          height: 20.0,
                        ),
                        const CommitteeMembersTable(),
                      ],
                    ),
                  );
                }

                return const GFLoader(
                  type: GFLoaderType.circle,
                );

              }
            ),
          ),
        ),
      ),
    );
  }
}
