import 'package:ahbabadmin/dialogs/inform_dialog.dart';
import 'package:ahbabadmin/dialogs/wait_dialog.dart';
import 'package:ahbabadmin/utilities/for_json.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:regexpattern/regexpattern.dart';
import 'package:sanitize_html/sanitize_html.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoanEditScreen extends StatelessWidget {
  final DocumentSnapshot application;
  LoanEditScreen(this.application, {Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final _loanAmountController = TextEditingController();
  final _paybackAmountController = TextEditingController();
  final _takeOutTimestampController = TextEditingController();
  final _paybackTimestampController = TextEditingController();
  final _timelineCommentController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    _loanAmountController.text = application.get('loanAmount').toString();
    if(application.get('status').toString() == 'accepted'){
      _paybackAmountController.text = application.get('paybackAmount').toString();
      _takeOutTimestampController.text = application.get('takeOutTimestamp').toString();
      _paybackTimestampController.text = application.get('dueTimestamp').toString();
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ঋণ আবেদন এডিট'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                ),
                child: const Text('ডাটাবেসে সেভ করুন'),
                onPressed: () async {
                  if(!_formKey.currentState!.validate()){
                    return;
                  }
                  showWaitDialog(context);
                  List<String> timeline = [];
                  try{
                    timeline = getListFromJSONArray(application.get('timeline'));
                  } catch(e){
                    1;
                  }
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  DateTime currentDate = DateTime.now();
                  String timelineComment = "${currentDate.year} ${currentDate.month} ${currentDate.day} ";
                  timelineComment += prefs.getString('username')! + " (" + prefs.getString('name')! +") : ";
                  if(_timelineCommentController.text.isNotEmpty){
                    timeline.add(timelineComment + " " + sanitizeHtml(_timelineCommentController.text));
                  }
                  timelineComment += "Amount " + _loanAmountController.text;
                  timelineComment += " Payback Amount " + _paybackAmountController.text;
                  timelineComment += " Take Out Date " + _takeOutTimestampController.text;
                  timelineComment += " Payback Date " + _paybackTimestampController.text;
                  timeline.add(timelineComment);

                  application.reference.update({
                    'status' : 'accepted',
                    'loanAmount' : _loanAmountController.text,
                    'paybackAmount' : _paybackAmountController.text,
                    'takeOutTimestamp' : _takeOutTimestampController.text,
                    'dueTimestamp' : _paybackTimestampController.text,
                    'timeline' : timeline,
                  }).then((value) async {
                    Navigator.of(context).pop();
                    await showInformDialog(context, 'সফল', 'ডাটাবেসে সেভ হয়েছে।');
                    Navigator.of(context).pop();
                  }, onError: (error) async {
                    Navigator.of(context).pop();
                    await showInformDialog(context, 'ব্যর্থ', 'ডাটাবেসে সেভ হয়নি। ইন্টারনেট সংযোগ চেক করে পরে আবার চেষ্টা করুন।');
                    Navigator.of(context).pop();
                  });
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFormField(
                          controller: _loanAmountController,
                          decoration: const InputDecoration(
                            labelText: 'প্রদত্ত ঋণের পরিমাণ',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value){
                            value = value?.trim();
                            if(value == null || !value.isNumeric()){
                              return 'এখানে শুধু ইংরেজি ডিজিট বসবে।';
                            }
                            _loanAmountController.text = value;
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _paybackAmountController,
                          decoration: const InputDecoration(
                            labelText: 'পরিশোধের পরিমাণ',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value){
                            value = value?.trim();
                            if(value == null || !value.isNumeric()){
                              return 'এখানে শুধু ইংরেজি ডিজিট বসবে।';
                            }
                            _paybackAmountController.text = value;
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _takeOutTimestampController,
                          decoration: const InputDecoration(
                              labelText: 'ঋণ প্রদানের তারিখ',
                              helperMaxLines: 5,
                              helperText: '২০২১ সালের ফেব্রুয়ারি মাসের ৮ তারিখ বুঝাতে 20210208 লিখুন।'
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value){
                            value = value?.trim();
                            if(value == null || !value.isNumeric()){
                              return 'এখানে শুধু ইংরেজি ডিজিট বসবে।';
                            }
                            _takeOutTimestampController.text = value;
                            if(value.length != 8){
                              return 'এখানে ঠিক ৮টি ইংরেজি ডিজিট বসবে।';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _paybackTimestampController,
                          decoration: const InputDecoration(
                              labelText: 'ঋণ পরিশোধের তারিখ',
                              helperMaxLines: 5,
                              helperText: '২০২১ সালের ফেব্রুয়ারি মাসের ৮ তারিখ বুঝাতে 20210208 লিখুন।'
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value){
                            value = value?.trim();
                            if(value == null || !value.isNumeric()){
                              return 'এখানে শুধু ইংরেজি ডিজিট বসবে।';
                            }
                            _paybackTimestampController.text = value;
                            if(value.length != 8){
                              return 'এখানে ঠিক ৮টি ইংরেজি ডিজিট বসবে।';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _timelineCommentController,
                          decoration: const InputDecoration(
                              labelText: 'মন্তব্য যোগ করুন',
                              helperMaxLines: 5,
                              helperText: 'এই ঋণের ব্যাপারে যেকোনো অতিরিক্ত তথ্য টুকে রাখুন।',
                          ),
                          minLines: 2,
                          maxLines: 5,
                          validator: (value){
                            value = value?.trim();
                            if(value == null || value.isEmpty){
                              return null;
                            }
                            _timelineCommentController.text = value;
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        getLoanWidget(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getLoanWidget() {
    String title = "ঋণটির/আবেদনটির তথ্যাবলি";
    String details = 'ঋণপ্রার্থীর সদস্য নম্বরঃ ' + application.get('applicantMemberID').toString();
    details += '\nআবেদনের অবস্থাঃ ' + application.get('status').toString();
    details += '\nঋণের পরিমাণঃ ' + application.get('loanAmount').toString();
    details += '\nপণ্যের বর্ণনাঃ ' + application.get('productDetails').toString();
    details += '\nলোনের মেয়াদঃ ' + application.get('loanPeriodInMonth').toString() + ' মাস';
    details += '\nনিতে চাচ্ছেন ' + application.get('expectedTakeOutMonth').toString() + ' মাসে';
    List<String> bailsmen =  getListFromJSONArray(application.get('bailsmenMemberIDs'));
    details += '\nজামিনদারদের সদস্য নম্বরঃ ' + bailsmen.join(', ');
    if(application.get('status').toString() == 'accepted'){
      details += '\nনিয়েছেন ' + application.get('takeOutTimestamp').toString() + ' তারিখে';
      details += '\nপরিশোধ করবেন ' + application.get('paybackAmount').toString();
      details += '\nপরিশোধ করবেন ' + application.get('dueTimestamp').toString() + ' তারিখে';
    }
    details += "\n* " + getListFromJSONArray(application.get('timeline')).reversed.join('\n* ');

    return Column(
      children: [
        SelectableText(
          title,
          style: const TextStyle(
            fontSize: 20.0,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        SelectableText(
          details,
        ),
      ],
    );

  }

}
