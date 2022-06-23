import 'package:ahbabadmin/screens/AllMembersScreen/all_members_screen.dart';
import 'package:ahbabadmin/screens/ChangeOwnPasswordScreen/change_own_password_screen.dart';
import 'package:ahbabadmin/screens/EditAMemberScreen/edit_a_member_screen.dart';
import 'package:ahbabadmin/screens/EditAdminsScreen/edit_admins_screen.dart';
import 'package:ahbabadmin/screens/EditCommitteeScreen/edit_committee_screen.dart';
import 'package:ahbabadmin/screens/EditMonthlySavingScreen/edit_monthly_saving_screen.dart';
import 'package:ahbabadmin/screens/EditPrinciplesScreen/edit_principles_screen.dart';
import 'package:ahbabadmin/screens/EditYearlySavingScreen/edit_yearly_saving_screen.dart';
import 'package:ahbabadmin/screens/EntryAMonthlySavingScreen/entry_a_saving_screen.dart';
import 'package:ahbabadmin/screens/NoticeScreen/notice_screen.dart';
import 'package:ahbabadmin/screens/add_member_screen.dart';
import 'package:flutter/material.dart';

import 'EntryAYearlySavingScreen/entry_a_yearly_saving_screen.dart';
import 'LoanManagementScreen/loan_management_screen.dart';
import 'login_screen.dart';
import '../auth/auth.dart';
import 'restricted_screen.dart';
import 'something_went_wrong_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "আল-আহবাব এডমিন",
      theme: ThemeData(fontFamily: 'SolaimanLipi'),
      home: const LoggedInOrNot(),
      onGenerateRoute: (routeSettings) {
        if (routeSettings.name == 'LogInScreen') {
          return MaterialPageRoute(builder: (context) {
            return const LogInPageScreen();
          });
        }
        if (routeSettings.name == 'RestrictedScreen') {
          return MaterialPageRoute(builder: (context) {
            return IndexScreen();
          });
        }
        if (routeSettings.name == EntryAMonthlySavingScreen.routeName) {
          return MaterialPageRoute(builder: (context) {
            return const EntryAMonthlySavingScreen();
          });
        }
        if (routeSettings.name == EntryAYearlySavingScreen.routeName) {
          return MaterialPageRoute(builder: (context) {
            return const EntryAYearlySavingScreen();
          });
        }
        if (routeSettings.name == EditMonthlySavingScreen.routeName) {
          return MaterialPageRoute(builder: (context) {
            return const EditMonthlySavingScreen();
          });
        }
        if (routeSettings.name == EditYearlySavingScreen.routeName) {
          return MaterialPageRoute(builder: (context) {
            return const EditYearlySavingScreen();
          });
        }
        if (routeSettings.name == LoanManagementScreen.routeName) {
          return MaterialPageRoute(builder: (context) {
            return const LoanManagementScreen();
          });
        }
        if (routeSettings.name == NoticeBoardManagementScreen.routeName) {
          return MaterialPageRoute(builder: (context) {
            return NoticeBoardManagementScreen();
          });
        }
        if (routeSettings.name == AllMembersScreen.routeName) {
          return MaterialPageRoute(builder: (context) {
            return const AllMembersScreen();
          });
        }
        if (routeSettings.name == EditAMemberScreen.routeName) {
          return MaterialPageRoute(builder: (context) {
            return const EditAMemberScreen();
          });
        }
        if (routeSettings.name == AddMemberScreen.routeName) {
          return MaterialPageRoute(builder: (context) {
            return const AddMemberScreen();
          });
        }
        if (routeSettings.name == EditCommitteeScreen.routeName) {
          return MaterialPageRoute(builder: (context) {
            return const EditCommitteeScreen();
          });
        }
        if (routeSettings.name == EditPrinciplesScreen.routeName) {
          return MaterialPageRoute(builder: (context) {
            return const EditPrinciplesScreen();
          });
        }
        if (routeSettings.name == EditAdminsScreen.routeName) {
          return MaterialPageRoute(builder: (context) {
            return const EditAdminsScreen();
          });
        }
        if (routeSettings.name == ChangeOwnPasswordScreen.routeName) {
          return MaterialPageRoute(builder: (context) {
            return const ChangeOwnPasswordScreen();
          });
        }
      },
    );
  }
}

class LoggedInOrNot extends StatefulWidget {
  const LoggedInOrNot({Key? key}) : super(key: key);

  @override
  _LoggedInOrNotState createState() => _LoggedInOrNotState();
}

class _LoggedInOrNotState extends State<LoggedInOrNot> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: logOut(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SomethingWentWrongScreen();
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return const LogInPageScreen();
        }

        return Container(
          color: Colors.white,
          child: const Center(
            child: Text(
              'দয়া করে\nকিছুক্ষণ\nঅপেক্ষা করুন!',
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Mina',
                fontWeight: FontWeight.w700,
                fontSize: 30.0,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        );
      },
    );
  }
}
