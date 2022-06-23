import 'package:ahbabadmin/screens/EditCommitteeScreen/committee_members.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddNewCommitteeMember extends StatelessWidget {

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _designationController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  AddNewCommitteeMember({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Text(
              'কমিটিতে নতুন সদস্য যোগ করুন',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 8.0,
          ),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'নাম লিখুন',
            ),
            validator: (value){
              value = value?.trim();
              if(value == null || value.isEmpty){
                return 'নাম লিখেননি।';
              }
              _nameController.text = value;
              return null;
            },
          ),
          const SizedBox(
            height: 8.0,
          ),
          TextFormField(
            controller: _designationController,
            decoration: const InputDecoration(
              labelText: 'পদবী লিখুন',
            ),
            validator: (value){
              value = value?.trim();
              if(value == null || value.isEmpty){
                return 'পদবী লিখেননি।';
              }
              _designationController.text = value;
              return null;
            },
          ),
          const SizedBox(
            height: 8.0,
          ),
          TextFormField(
            controller: _phoneNumberController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'ফোন নম্বর লিখুন',
            ),
            validator: (value){
              value = value?.trim();
              if(value == null || value.isEmpty){
                return 'ফোন নম্বর লিখেননি।';
              }
              _phoneNumberController.text = value;
              return null;
            },
          ),
          const SizedBox(
            height: 8.0,
          ),
          ElevatedButton(
            child: const Text('নিচের তালিকায় যোগ করুন',),
            onPressed: () async{
              if(! _formKey.currentState!.validate()){
                return;
              }
              Map<String, dynamic> newMember = {
                'name' : _nameController.text,
                'designation' : _designationController.text,
                'phone' : _phoneNumberController.text,
              };
              context.read<CommitteeMembers>().add(newMember);
              context.read<CommitteeMembers>().notify();
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                      'ডাটাবেসে হালনাগাদ হয়নি কিন্তু',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    content: const Text('প্রয়োজনে টেবিলের সারি ড্র্যাগ করে পুনর্বিন্যাস করে নিচের বাটন চেপে ডাটাবেসে টেবিলটি হালনাগাদ করতে ভুলবেন না।'),
                    actions: [
                      TextButton(
                        child: const Text('বেশ!'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
              _formKey.currentState!.reset();
            },
          ),
        ],
      ),
    );
  }
}
