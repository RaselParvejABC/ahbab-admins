import 'package:ahbabadmin/screens/LoanManagementScreen/accepted_loans.dart';
import 'package:ahbabadmin/screens/LoanManagementScreen/paid_loans.dart';
import 'package:ahbabadmin/screens/LoanManagementScreen/pending_loan_applications.dart';

import 'package:flutter/material.dart';

class LoanManagementScreen extends StatefulWidget {
  static get label => "ঋণ ব্যবস্থাপনা";
  static get requiredAdminPrivilege => "loan-management";
  static get routeName => "LoanManagementScreen";


  const LoanManagementScreen({Key? key}) : super(key: key);

  @override
  State<LoanManagementScreen> createState() => _LoanManagementScreenState();
}

class _LoanManagementScreenState extends State<LoanManagementScreen> {
  int _selectedIndex = 0;


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(LoanManagementScreen.label),
        ),
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: IndexedStack(
            index: _selectedIndex,
            children: const [
              PendingLoanApplications(),
              AcceptedLoans(),
              PaidLoans(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          iconSize: 16.0,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.pending),
              label: 'অমীমাংসিত',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.approval_rounded),
              label: 'অনুমোদিত',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.cloud_done),
              label: 'পরিশোধিত',
            ),
          ],
        ),
      ),
    );
  }


}
