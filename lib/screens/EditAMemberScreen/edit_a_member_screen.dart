import 'package:ahbabadmin/screens/EditAMemberScreen/edit_a_member_form.dart';
import 'package:flutter/material.dart';
import 'package:regexpattern/regexpattern.dart';

class EditAMemberScreen extends StatefulWidget {
  static String get label => "সদস্যের তথ্য এডিট";
  static String get requiredAdminPrivilege => "member-edit";
  static String get routeName => "EditAMemberScreen";
  const EditAMemberScreen({Key? key}) : super(key: key);

  @override
  _EditAMemberScreenState createState() => _EditAMemberScreenState();
}

class _EditAMemberScreenState extends State<EditAMemberScreen> {
  final _memberFormKey = GlobalKey<FormState>();
  final _memberRegistrationNumberController = TextEditingController();


  bool _showEditForm = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(EditAMemberScreen.label),
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
                            _showEditForm = true;
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
              if(_showEditForm) Expanded(
                child: EditAMemberForm(_memberRegistrationNumberController.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
