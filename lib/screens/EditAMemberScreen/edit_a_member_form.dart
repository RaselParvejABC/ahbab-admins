import 'dart:convert';
import 'dart:io';

import 'package:ahbabadmin/auth/cryptography.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/getwidget.dart';
import 'package:http/http.dart' as http;
import 'package:regexpattern/regexpattern.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sanitize_html/sanitize_html.dart';

import '../../auth/auth.dart';

class EditAMemberForm extends StatefulWidget {
  final String memberRegistrationNumber;
  const EditAMemberForm(this.memberRegistrationNumber, {Key? key}) : super(key: key);

  @override
  State<EditAMemberForm> createState() => _EditAMemberFormState();
}

class _EditAMemberFormState extends State<EditAMemberForm> {
  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  bool isActivated = false;
  String? _profileImagePath;
  String? _profileImageLink;
  String? _profileImageDeleteLink;
  final _nameInEnglishLettersController = TextEditingController();
  final _nameInBanglaLettersController = TextEditingController();
  final _emailAddressController = TextEditingController();
  final _phoneNumbersController = TextEditingController();
  final _addressInQatarController = TextEditingController();
  final _addressInBangladeshController = TextEditingController();
  final _passportNumberController = TextEditingController();
  final _theNIDController = TextEditingController();
  final _theQIDController = TextEditingController();
  final _monthlyFixedAmountController = TextEditingController();
  final _refererDataController = TextEditingController();
  final _nomineeDataController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('members').doc(widget.memberRegistrationNumber).get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('কিছু একটা সমস্যা হয়েছে। এ্যাপ বন্ধ করে ইন্টারনেট সংযোগ চেক করে আবার চেষ্টা করুন।');
        }
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          DocumentSnapshot memberDocSnap = snapshot.data as DocumentSnapshot;
          if (!memberDocSnap.exists) {
            return const Text('এই রেজিস্ট্রেশন নম্বরের কোনো সদস্য নেই।');
          }
          Map<String, dynamic> memberData = memberDocSnap.data() as Map<String, dynamic>;

          isActivated = memberData['isActivated'] == 'true';
          _profileImageLink = memberData['profileImageLink'];
          _profileImageDeleteLink = memberData['profileImageDeleteLink'];

          _nameInEnglishLettersController.text = memberData['nameInEnglishLetters'];
          _nameInBanglaLettersController.text = memberData['nameInBanglaLetters'];
          _emailAddressController.text = memberData['emailAddress'];
          _phoneNumbersController.text = memberData['phoneNumbers'];
          _addressInQatarController.text = memberData['addressInQatar'];
          _addressInBangladeshController.text = memberData['addressInBangladesh'];
          _passportNumberController.text = memberData['passportNumber'];
          _theNIDController.text = memberData['NID'];
          _theQIDController.text = memberData['QID'];
          _monthlyFixedAmountController.text = memberData['monthlyFixedAmount'];
          _refererDataController.text = memberData['refererData'];
          _nomineeDataController.text = memberData['nomineeData'];

          return Container(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'যে তথ্য পরিবর্তন করতে চান না, সে তথ্যের ঘর অপরিবর্তিত রাখুন।',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  ElevatedButton(
                    child: const Text('ডাটাবেসে সেভ করুন'),
                    onPressed: () async {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.white,
                            duration: Duration(
                              hours: 1, //Something Long Enough
                            ),
                            dismissDirection: DismissDirection.none,
                            content: LinearProgressIndicator(
                              color: Colors.blue,
                              value: null,
                            ),
                          ),
                        );
                        String? errorMessage = await checkSessionKey();
                        if (errorMessage != "") {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          Navigator.pushReplacementNamed(context, 'LogInScreen');
                        } else {
                          DocumentSnapshot? userDocSnap;
                          try {
                            userDocSnap = await FirebaseFirestore.instance
                                .collection('members')
                                .doc(widget.memberRegistrationNumber)
                                .get(const GetOptions(source: Source.server));
                          } catch (error) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('ইন্টারনেট বা সার্ভার সমস্যা'),
                                  content:
                                      const Text('সার্ভারে যুক্ত হওয়া যাচ্ছে না। ইন্টারনেট সংযোগ চেক করুন।\nতাও না হলে, কিছুক্ষণ পরে চেষ্টা করুন।'),
                                  actions: [
                                    TextButton(
                                      child: const Text('ওকে'),
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                  ],
                                );
                              },
                            );
                            return;
                          }
                          late Map<String, dynamic> dataObject;
                          if(_profileImagePath != null){
                            //create multipart request for POST or PATCH method
                            http.MultipartRequest request = http.MultipartRequest("POST", Uri.parse("https://api.imgbb.com/1/upload"));
                            //add text fields
                            request.fields["key"] = "5194aae0b4e48c22de17f04438b29e20";
                            request.fields["name"] = widget.memberRegistrationNumber;
                            //create multipart using filepath, string or bytes
                            http.MultipartFile profilePicture = await http.MultipartFile.fromPath("image", _profileImagePath!);
                            //add multipart to request
                            request.files.add(profilePicture);
                            http.StreamedResponse? response;
                            try {
                              response = await request.send();
                            } catch (error) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('ইন্টারনেট বা সার্ভার সমস্যা'),
                                    content: const Text(
                                        'ইমেজ সার্ভারে যুক্ত হওয়া যাচ্ছে না। ইন্টারনেট সংযোগ চেক করুন।\nতাও না হলে, কিছুক্ষণ পরে চেষ্টা করুন।'),
                                    actions: [
                                      TextButton(
                                        child: const Text('ওকে'),
                                        onPressed: () => Navigator.of(context).pop(),
                                      ),
                                    ],
                                  );
                                },
                              );
                              return;
                            }
                            if (response.statusCode != 200) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.deepPurpleAccent,
                                  content: Text(
                                    "ছবি আপলোডে সমস্যা হয়েছে!\nকিছুক্ষণ পরে আবার চেষ্টা করুন।",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'SolaimanLipi',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                              return;
                            }

                            String responseString = await response.stream.bytesToString();
                            var responseObject = jsonDecode(responseString);
                            dataObject = responseObject["data"];


                            try{
                              //Deleting Previous Image
                              await http.get(Uri.parse(_profileImageDeleteLink!));
                            } catch(error){
                              //print('error: ' + error.toString());
                              1;
                            }


                            _profileImageLink = dataObject["display_url"];
                            _profileImageDeleteLink = dataObject["delete_url"];

                          }

                          userDocSnap.reference.update({
                            if(_passwordController.text.isNotEmpty)
                              'passwordHash': getSHA256Hash(sanitizeHtml(_passwordController.text)),
                            if(_passwordController.text.isNotEmpty)
                              'sessionKeys': [],
                            'isActivated': sanitizeHtml(isActivated.toString()),
                            'profileImageLink': sanitizeHtml(_profileImageLink!),
                            'profileImageDeleteLink': sanitizeHtml(_profileImageDeleteLink!),
                            'nameInEnglishLetters': sanitizeHtml(_nameInEnglishLettersController.text),
                            'nameInBanglaLetters': sanitizeHtml(_nameInBanglaLettersController.text),
                            'emailAddress': sanitizeHtml(_emailAddressController.text),
                            'phoneNumbers': sanitizeHtml(_phoneNumbersController.text),
                            'addressInQatar': sanitizeHtml(_addressInQatarController.text),
                            'addressInBangladesh': sanitizeHtml(_addressInBangladeshController.text),
                            'passportNumber': sanitizeHtml(_passportNumberController.text),
                            'NID': sanitizeHtml(_theNIDController.text),
                            'QID': sanitizeHtml(_theQIDController.text),
                            'monthlyFixedAmount': sanitizeHtml(_monthlyFixedAmountController.text),
                            'refererData': sanitizeHtml(_refererDataController.text),
                            'nomineeData': sanitizeHtml(_nomineeDataController.text),
                          }).then((value) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('সফল'),
                                  content: const Text('সদস্যের তথ্য হালনাগাদ হয়েছে।'),
                                  actions: [
                                    TextButton(
                                      child: const Text('ওকে'),
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                  ],
                                );
                              },
                            );
                            setState(() {});
                          }, onError: (error) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.deepPurpleAccent,
                                content: Text(
                                  "ডাটাবেসে ডাটাবসে হালনাগাদ হয়নি।\nকিছুক্ষণ পরে আবার চেষ্টা করুন।",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'SolaimanLipi',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          });
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.deepPurpleAccent,
                            content: Text(
                              "সব তথ্য ঠিকঠাক পূরণ করেননি!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'SolaimanLipi',
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: _passwordController,
                            keyboardType: TextInputType.number,
                            obscureText: false,
                            decoration: const InputDecoration(
                              labelText: 'পাসওয়ার্ড',
                            ),
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return null;
                              }
                              if (value.length < 8) {
                                return 'পাসওয়ার্ড কমপক্ষে 8 (আট) ক্যারাক্টারের লিখুন।';
                              }
                              return null;
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "এক্টিভ্যাটেড?",
                                style: TextStyle(
                                  //color: Colors.blueAccent,
                                  //fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              Switch(
                                  value: isActivated,
                                  onChanged: (newValue) => setState(() {
                                        isActivated = newValue;
                                      })),
                            ],
                          ),
                          const SizedBox(
                            height: 16.0,
                          ),
                          GestureDetector(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_profileImagePath == null)
                                  Image.network(
                                    _profileImageLink!,
                                    width: 100.0,
                                  ),
                                if (_profileImagePath != null)
                                  Image.file(
                                    File(_profileImagePath!),
                                    width: 100.0,
                                  ),
                              ],
                            ),
                            onTap: () async {
                              final ImagePicker _picker = ImagePicker();
                              final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                              if (image == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.white,
                                    content: Text(
                                      "দয়া করে আবার ছবি বাছাই করুন!",
                                      style: TextStyle(
                                        fontFamily: 'SolaimanLipi',
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                setState(() {
                                  _profileImagePath = image.path;
                                });
                              }
                            },
                          ),
                          TextFormField(
                            controller: _nameInBanglaLettersController,
                            decoration: const InputDecoration(
                              hintText: 'বাংলা হরফে সদস্যের নাম লিখুন।',
                              labelText: 'বাংলা হরফে সদস্যের নাম',
                            ),
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              value = value?.trim();
                              if (value == null || value.isEmpty) {
                                return 'নাম লিখেননি!';
                              }
                              _nameInBanglaLettersController.text = value;
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _nameInEnglishLettersController,
                            decoration: const InputDecoration(
                              hintText: 'ইংরেজি হরফে সদস্যের নাম লিখুন।',
                              labelText: 'ইংরেজি হরফে সদস্যের নাম',
                            ),
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              value = value?.trim();
                              if (value == null || value.isEmpty) {
                                return 'নাম লিখেননি!';
                              }
                              _nameInEnglishLettersController.text = value;
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _emailAddressController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'সদস্যের ই-মেইল অ্যাড্রেস লিখুন।',
                              labelText: 'সদস্যের ই-মেইল অ্যাড্রেস',
                            ),
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              value = value?.trim();
                              if (value == null || value.isEmpty) {
                                return null; //Making email address optional
                              }
                              _emailAddressController.text = value;
                              if (!value.isEmail()) {
                                return 'ই-মেইল অ্যাড্রেস সঠিক নয়।';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _phoneNumbersController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'সদস্যের ফোন নম্বরগুলো স্পেস দিয়ে একটি করে লিখুন।',
                              labelText: 'সদস্যের ফোন নম্বরসমূহ',
                            ),
                            minLines: 1,
                            maxLines: 3,
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              value = value?.trim();
                              if (value == null || value.isEmpty) {
                                return 'ফোন নম্বর লিখেননি';
                              }
                              _phoneNumbersController.text = value;
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _addressInQatarController,
                            decoration: const InputDecoration(
                              hintText: 'কাতারে সদস্যের ঠিকানা লিখুন',
                              labelText: 'সদস্যের ঠিকানা (কাতার)',
                            ),
                            minLines: 1,
                            maxLines: 3,
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              value = value?.trim();
                              if (value == null || value.isEmpty) {
                                return 'ঠিকানা লিখেননি';
                              }
                              _addressInQatarController.text = value;
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _addressInBangladeshController,
                            decoration: const InputDecoration(
                              hintText: 'বাংলাদেশে সদস্যের ঠিকানা লিখুন',
                              labelText: 'সদস্যের ঠিকানা (বাংলাদেশ)',
                            ),
                            minLines: 1,
                            maxLines: 3,
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              value = value?.trim();
                              if (value == null || value.isEmpty) {
                                return 'ঠিকানা লিখেননি';
                              }
                              _addressInBangladeshController.text = value;
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _passportNumberController,
                            decoration: const InputDecoration(
                              hintText: 'সদস্যের পাসপোর্ট নম্বর লিখুন',
                              labelText: 'সদস্যের পাসপোর্ট নম্বর',
                            ),
                            minLines: 1,
                            maxLines: 2,
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              value = value?.trim();
                              if (value == null || value.isEmpty) {
                                return 'পাসপোর্ট নম্বর লিখেননি';
                              }
                              _passportNumberController.text = value;
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _theNIDController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'সদস্যের বাংলাদেশি জাতীয় পরিচয়পত্রের নম্বর লিখুন',
                              labelText: 'সদস্যের জাতীয় পরিচয়পত্র নম্বর',
                            ),
                            minLines: 1,
                            maxLines: 2,
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              value = value?.trim();
                              if (value == null || value.isEmpty) {
                                return null; //Making it optional field
                              }
                              _theNIDController.text = value;
                              if (!value.isNumeric()) {
                                return 'জাতীয় পরিচয়পত্র নম্বরে শুধু ডিজিট থাকবে।';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _theQIDController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'সদস্যের কাতার আইডি নম্বর লিখুন',
                              labelText: 'সদস্যের কাতার আইডি নম্বর',
                            ),
                            minLines: 1,
                            maxLines: 2,
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              value = value?.trim();
                              if (value == null || value.isEmpty) {
                                return null; //Making it optional
                              }
                              _theQIDController.text = value;
                              if (!value.isNumeric()) {
                                return 'কাতার আইডি নম্বরে শুধু ডিজিট থাকবে।';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _monthlyFixedAmountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: ' ধার্য্যকৃত মাসিক চাঁদার পরিমাণ লিখুন (ইংরেজি ডিজিটে)',
                              labelText: 'সদস্যের ধার্য্যকৃত মাসিক চাঁদার পরিমাণ (QR)',
                            ),
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              value = value?.trim();
                              if (value == null || value.isEmpty) {
                                return 'ধার্য্যকৃত মাসিক চাঁদার পরিমাণ লিখেননি!';
                              }
                              _monthlyFixedAmountController.text = value;
                              if (!value.isNumeric()) {
                                return 'চাঁদার পরিমাণে শুধু ইংরেজি ডিজিট বসবে।';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _refererDataController,
                            keyboardType: TextInputType.multiline,
                            decoration: const InputDecoration(
                              hintText: 'সদস্যের রেফারারের তথ্য লিখুন',
                              labelText: 'সদস্যের রেফারারের তথ্য',
                              helperText: 'ওপরে যা যা লিখবেন—\nরেফারারের নাম, রেফারার সদস্যের কী হোন,\nরেফারারের ফোন নম্বর, এনআইডি ও কাতার আইডি',
                              helperStyle: TextStyle(
                                color: Colors.black87,
                              ),
                            ),
                            minLines: 1,
                            maxLines: 8,
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'রেফারারের তথ্য লিখেননি';
                              }
                              _refererDataController.text = value.trim();
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _nomineeDataController,
                            keyboardType: TextInputType.multiline,
                            decoration: const InputDecoration(
                              hintText: 'সদস্যের নমিনির তথ্য লিখুন',
                              labelText: 'সদস্যের নমিনির তথ্য',
                              helperText: 'ওপরে যা যা লিখবেন—\nনমিনির নাম, নমিনি সদস্যের কী হোন,\nনমিনির ফোন নম্বর, এনআইডি ও ঠিকানা',
                              helperStyle: TextStyle(
                                color: Colors.black87,
                              ),
                            ),
                            minLines: 1,
                            maxLines: 8,
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'নমিনির তথ্য লিখেননি';
                              }
                              _nomineeDataController.text = value.trim();
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const GFLoader(
          type: GFLoaderType.circle,
          size: GFSize.LARGE,
        );
      },
    );
  }
}
