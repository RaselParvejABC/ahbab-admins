import 'package:flutter/material.dart';
import 'package:regexpattern/regexpattern.dart';

import 'edit_monthly_saving_form.dart';


class EditMonthlySavingScreen extends StatefulWidget {
  static String get label => "মাসিক সঞ্চয় এডিট";
  static String get requiredAdminPrivilege => "monthly-deposit-edit";
  static String get routeName => "EditMonthlySavingScreen";

  const EditMonthlySavingScreen({Key? key}) : super(key: key);

  @override
  _EditMonthlySavingScreenState createState() => _EditMonthlySavingScreenState();
}

class _EditMonthlySavingScreenState extends State<EditMonthlySavingScreen> {
  final _memberFormKey = GlobalKey<FormState>();
  final _memberRegistrationNumberController = TextEditingController();


  bool _showSavingForm = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(EditMonthlySavingScreen.label),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Form(
                key: _memberFormKey,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _memberRegistrationNumberController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'সদস্যের রেজিস্ট্রেশন নম্বর',
                        ),
                        validator: (value) {
                          value = value?.trim();
                          if(value == null || value.isEmpty) {
                            return 'সদস্য নম্বর লিখুন।';
                          }
                          _memberRegistrationNumberController.text = value;
                          if(!value.isNumeric()){
                            return 'সদস্য নম্বরে শুধু ইংরেজি ডিজিট থাকবে।';
                          }
                          return null;
                        },
                      ),
                    ),
                    ElevatedButton(
                      child: const Text('জমার ফর্ম দেখুন'),
                      onPressed: () {
                        if(_memberFormKey.currentState!.validate()){
                          setState(() {
                            _showSavingForm = true;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              if(_showSavingForm) Expanded(
                child: EditMonthlySavingForm(_memberRegistrationNumberController.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
