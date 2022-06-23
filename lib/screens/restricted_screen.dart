import 'package:ahbabadmin/auth/auth.dart';
import 'package:ahbabadmin/dialogs/wait_dialog.dart';
import 'package:ahbabadmin/screens/AllMembersScreen/all_members_screen.dart';
import 'package:ahbabadmin/screens/ChangeOwnPasswordScreen/change_own_password_screen.dart';
import 'package:ahbabadmin/screens/EditAMemberScreen/edit_a_member_screen.dart';
import 'package:ahbabadmin/screens/EditAdminsScreen/edit_admins_screen.dart';
import 'package:ahbabadmin/screens/EditCommitteeScreen/edit_committee_screen.dart';
import 'package:ahbabadmin/screens/EditMonthlySavingScreen/edit_monthly_saving_screen.dart';
import 'package:ahbabadmin/screens/EditPrinciplesScreen/edit_principles_screen.dart';
import 'package:ahbabadmin/screens/EditYearlySavingScreen/edit_yearly_saving_screen.dart';
import 'package:ahbabadmin/screens/LoanManagementScreen/loan_management_screen.dart';
import 'package:ahbabadmin/screens/add_member_screen.dart';
import 'package:ahbabadmin/utilities/for_json.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'EntryAMonthlySavingScreen/entry_a_saving_screen.dart';
import 'EntryAYearlySavingScreen/entry_a_yearly_saving_screen.dart';
import 'NoticeScreen/notice_screen.dart';

class IndexScreen extends StatelessWidget {
  IndexScreen({Key? key}) : super(key: key);

  late final Map<String, dynamic> adminData;
  late final String adminUsername;
  late final List<String> adminPrivileges;

  Future getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    adminUsername = prefs.getString('username')!;
    adminData = (await FirebaseFirestore.instance.collection('admins').doc(adminUsername).get()).data()!;
    adminPrivileges = getListFromJSONArray(adminData['privileges']);
    return;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: FutureBuilder(
            future: getData(),
            builder: (context, snapshot){
              if(snapshot.hasError){
                return const Text('কিছু একটা সমস্যা হয়েছে। ইন্টারনেট সংযোগ চেক করে আবার চেষ্টা করুন।');
              }
              if(snapshot.connectionState == ConnectionState.done){
                return Column(
                  children: [
                    Text(
                      'আপনি\nএডমিন (' + adminUsername + ') হিসেবে\nলগড ইন‌ আছেন।',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Mina',
                      ),
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(''),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                          ),
                          child: const Text(
                              'লগ্‌ আউট',
                          ),
                          onPressed: () async {
                            showWaitDialog(context);
                            await logOut();
                            Navigator.of(context).pop();
                            Navigator.of(context).pushReplacementNamed("LogInScreen");
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 3,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          children: screens
                              .where((screen) => adminPrivileges.contains("all") || adminPrivileges.contains(screen['requiredAdminPrivilege']))
                              .map((screen) {
                            return ElevatedButton(
                              child: Text(
                                  screen['label']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: (){
                                Navigator.of(context).pushNamed(screen['routeName']!);
                              },
                            );
                          }).toList(),
                      ),
                    ),
                  ],
                );
              }
              return const GFLoader();
            },
          ),
        ),
      ),
    );
  }

  static List<Map<String, String>> screens = [
    {
      'label' : AllMembersScreen.label,
      'requiredAdminPrivilege' : AllMembersScreen.requiredAdminPrivilege,
      'routeName' : AllMembersScreen.routeName,
    },
    {
      'label' : EntryAMonthlySavingScreen.label,
      'requiredAdminPrivilege' : EntryAMonthlySavingScreen.requiredAdminPrivilege,
      'routeName' : EntryAMonthlySavingScreen.routeName,
    },
    {
      'label' : EntryAYearlySavingScreen.label,
      'requiredAdminPrivilege' : EntryAYearlySavingScreen.requiredAdminPrivilege,
      'routeName' : EntryAYearlySavingScreen.routeName,
    },
    {
      'label' : EditMonthlySavingScreen.label,
      'requiredAdminPrivilege' : EditMonthlySavingScreen.requiredAdminPrivilege,
      'routeName' : EditMonthlySavingScreen.routeName,
    },
    {
      'label' : EditYearlySavingScreen.label,
      'requiredAdminPrivilege' : EditYearlySavingScreen.requiredAdminPrivilege,
      'routeName' : EditYearlySavingScreen.routeName,
    },
    {
      'label' : LoanManagementScreen.label,
      'requiredAdminPrivilege' : LoanManagementScreen.requiredAdminPrivilege,
      'routeName' : LoanManagementScreen.routeName,
    },
    {
      'label' : NoticeBoardManagementScreen.label,
      'requiredAdminPrivilege' : NoticeBoardManagementScreen.requiredAdminPrivilege,
      'routeName' : NoticeBoardManagementScreen.routeName,
    },
    {
      'label' : EditAMemberScreen.label,
      'requiredAdminPrivilege' : EditAMemberScreen.requiredAdminPrivilege,
      'routeName' : EditAMemberScreen.routeName,
    },
    {
      'label' : AddMemberScreen.label,
      'requiredAdminPrivilege' : AddMemberScreen.requiredAdminPrivilege,
      'routeName' : AddMemberScreen.routeName,
    },
    {
      'label' : EditCommitteeScreen.label,
      'requiredAdminPrivilege' : EditCommitteeScreen.requiredAdminPrivilege,
      'routeName' : EditCommitteeScreen.routeName,
    },
    {
      'label' : EditPrinciplesScreen.label,
      'requiredAdminPrivilege' : EditPrinciplesScreen.requiredAdminPrivilege,
      'routeName' : EditPrinciplesScreen.routeName,
    },
    {
      'label' : EditAdminsScreen.label,
      'requiredAdminPrivilege' : EditAdminsScreen.requiredAdminPrivilege,
      'routeName' : EditAdminsScreen.routeName,
    },
    {
      'label' : ChangeOwnPasswordScreen.label,
      'requiredAdminPrivilege' : ChangeOwnPasswordScreen.requiredAdminPrivilege,
      'routeName' : ChangeOwnPasswordScreen.routeName,
    },
  ];

}
