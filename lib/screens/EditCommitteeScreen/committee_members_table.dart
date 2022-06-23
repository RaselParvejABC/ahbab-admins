import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/getwidget.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';

import 'committee_members.dart';

class CommitteeMembersTable extends StatelessWidget {
  const CommitteeMembersTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CommitteeMembers committeeMembers = context.watch<CommitteeMembers>();

    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _handleSaveToDatabase(context),
          child: const Text(
            'নিচের তালিকার তথ্য ডাটাবেসে সেভ করুন',
          ),
        ),
        if (committeeMembers.getList().isEmpty) const Text('কমিটি নেই।'),
        if (committeeMembers.getList().isNotEmpty)
          const Text(
            'পুনর্বিন্যাস করতে ড্র্যাগ করে কাঙ্ক্ষিত অবস্থানে ড্রপ করুন।',
            textAlign: TextAlign.center,
          ),
        if (committeeMembers.getList().isNotEmpty)
          ReorderableColumn(
            onReorder: (int oldIndex, int newIndex) {
              if (oldIndex < newIndex) {
                newIndex--;
              }
              committeeMembers.addAtIndex(committeeMembers.delete(oldIndex), newIndex);
              committeeMembers.notify();
            },
            children: [
              for (int i = 0; i < committeeMembers.getList().length; i++) _getListTile(committeeMembers.getList().elementAt(i), i, context),
            ],
          ),
      ],
    );
  }

  _getListTile(Map<String, dynamic> member, int index, BuildContext context) {
    return DefaultTextStyle(
      key: ObjectKey(member),
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      child: Container(
        margin: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.lightBlue,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(5.0))),
        child: GFListTile(
          padding: const EdgeInsets.all(2.0),
          margin: EdgeInsets.zero,
          color: Colors.white,
          titleText: member['name'],
          subTitleText: member['designation'],
          description: Text(member['phone']),
          icon: IconButton(
            icon: const Icon(
              Icons.delete,
            ),
            onPressed: () => _handleDelete(index, context),
          ),
          avatar: IconButton(
            icon: const Icon(
              Icons.edit,
            ),
            onPressed: () => _handleEdit(member, context),
          ),
        ),
      ),
    );
  }

  _handleDelete(int index, BuildContext context) async {
    Map<String, dynamic> memberToBeDeleted = context.read<CommitteeMembers>().getList().elementAt(index);
    bool toDelete = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'ডিলিট করতে চাচ্ছেন?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(memberToBeDeleted['name']),
              Text(memberToBeDeleted['designation']),
              Text(memberToBeDeleted['phone']),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('হ্যাঁ'),
              onPressed: () {
                toDelete = true;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('না'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    if (toDelete) {
      context.read<CommitteeMembers>().delete(index);
      context.read<CommitteeMembers>().notify();
    }
    return;
  }

  _handleEdit(Map<String, dynamic> member, BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _designationController = TextEditingController();
    final _phoneNumberController = TextEditingController();

    _nameController.text = member['name'];
    _designationController.text = member['designation'];
    _phoneNumberController.text = member['phone'];

    bool toEdit = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'এডিট করুন',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'নাম লিখুন',
                      hintText: member['name'],
                    ),
                    validator: (value) {
                      value = value?.trim();
                      if (value == null || value.isEmpty) {
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
                    validator: (value) {
                      value = value?.trim();
                      if (value == null || value.isEmpty) {
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
                    validator: (value) {
                      value = value?.trim();
                      if (value == null || value.isEmpty) {
                        return 'ফোন নম্বর লিখেননি।';
                      }
                      _phoneNumberController.text = value;
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('সেভ করুন'),
              onPressed: () {
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                toEdit = true;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('বাতিল'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    if (toEdit) {
      member['name'] = _nameController.text;
      member['designation'] = _designationController.text;
      member['phone'] = _phoneNumberController.text;
      context.read<CommitteeMembers>().notify();
    }
    return;
  }

  _handleSaveToDatabase(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text(
            'দয়া করে কিছুক্ষণ অপেক্ষা করুন।',
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            height: 40.0,
            child: GFLoader(
              type: GFLoaderType.circle,
              size: GFSize.SMALL,
            ),
          ),
        );
      },
    );

    FirebaseFirestore.instance.collection('ahbabVariables').doc('committee').set({
      'members': context.read<CommitteeMembers>().getList(),
    }).then((value) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'সফল',
              textAlign: TextAlign.center,
            ),
            content: const Text('ডাটাবেসে সেভ হয়েছে।'),
            actions: [
              TextButton(
                child: const Text('বেশ!'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    }, onError: (error) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'ব্যর্থ',
              textAlign: TextAlign.center,
            ),
            content: const Text('ডাটাবেসে সেভ হয়নি। ইন্টারনেট সংযোগ চেক করে আবার চেষ্টা করুন।'),
            actions: [
              TextButton(
                child: const Text('বেশ!'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    });
  }
}
