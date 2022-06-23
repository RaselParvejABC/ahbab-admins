import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MemberInformationScreen extends StatelessWidget {
  final DocumentSnapshot memberDocSnap;
  const MemberInformationScreen(this.memberDocSnap, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('সদস্যের তথ্য'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Table(
              border: TableBorder.all(
                borderRadius: const BorderRadius.all(Radius.elliptical(3, 4)),
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                1: FlexColumnWidth(2.0),
              },
              children: [
                TableRow(children: getTableRowCells('সদস্য নম্বর', memberDocSnap.reference.id)),
                TableRow(children: getTableRowCells('নির্ধারিত মাসিক চাঁদা', memberDocSnap.get('monthlyFixedAmount').toString())),
                TableRow(children: getTableRowCells('নাম (ইংরেজি)', memberDocSnap.get('nameInEnglishLetters').toString())),
                TableRow(children: getTableRowCells('নাম (বাংলা)', memberDocSnap.get('nameInBanglaLetters').toString())),
                TableRow(children: getTableRowCells('তড়িৎডাক', memberDocSnap.get('emailAddress').toString())),
                TableRow(children: getTableRowCells('দূরালাপন', memberDocSnap.get('phoneNumbers').toString().split(RegExp(r"\s+")).join("\n"))),
                TableRow(children: getTableRowCells('পাসপোর্ট নম্বর', memberDocSnap.get('passportNumber').toString())),
                TableRow(children: getTableRowCells('কাতার আইডি', memberDocSnap.get('QID').toString())),
                TableRow(children: getTableRowCells('এনআইডি', memberDocSnap.get('NID').toString())),
                TableRow(children: getTableRowCells('ঠিকানা (কাতার)', memberDocSnap.get('addressInQatar').toString())),
                TableRow(children: getTableRowCells('ঠিকানা (বাংলাদেশ)', memberDocSnap.get('addressInBangladesh').toString())),
                TableRow(children: getTableRowCells('নমিনি', memberDocSnap.get('nomineeData').toString())),
                TableRow(children: getTableRowCells('রেফারার', memberDocSnap.get('refererData').toString())),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getTableRowCells(String key, String value) {
    return [
      getTableCell(key),
      getTableCell(value),
    ];
  }

  Widget getTableCell(String content) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SelectableText(content),
    );
  }
}
