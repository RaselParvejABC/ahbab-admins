import 'package:ahbabadmin/screens/AllMembersScreen/member_information_screen.dart';
import 'package:ahbabadmin/services/firestore/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:provider/provider.dart';
import 'package:stream_transform/stream_transform.dart';

class AllMembersScreen extends StatefulWidget {
  static String get label => "সদস্যদের তথ্য";
  static String get requiredAdminPrivilege => "member-read";
  static String get routeName => "AllMembersScreen";
  const AllMembersScreen({Key? key}) : super(key: key);

  @override
  _AllMembersScreenState createState() => _AllMembersScreenState();
}

class _AllMembersScreenState extends State<AllMembersScreen> {
  Stream<QuerySnapshot<Map<String, dynamic>>> membersSnapshot = FirebaseFirestore.instance.collection('members').snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> acceptedLoansSnapshots =
      FirebaseFirestore.instance.collection('loanApplications').where('status', isEqualTo: 'accepted').orderBy('dueTimestamp').snapshots();

  late List<DocumentSnapshot<Map<String, dynamic>>> members, acceptedLoans;

  final searchKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => SearchKey(),
        ),
      ],
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(AllMembersScreen.label),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder(
              stream: membersSnapshot.combineLatestAll([acceptedLoansSnapshots]),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('কিছু একটা সমস্যা হয়েছে। ইন্টারনেট সংযোগ চেক করে পরে আবার চেষ্টা করুন।');
                }
                if (snapshot.hasData) {
                  String searchKey = context.watch<SearchKey>().getKey;
                  List<List<DocumentSnapshot<Map<String, dynamic>>>> snapshots =
                      (snapshot.data as List<QuerySnapshot<Map<String, dynamic>>>).map((e) => e.docs).toList();
                  members = snapshots.first;
                  if(searchKey != ""){
                    members = members.where((member) => member.reference.id == searchKey).toList();
                  }

                  acceptedLoans = snapshots.last;

                  searchKeyController.selection = TextSelection.fromPosition(TextPosition(offset: searchKeyController.text.length));

                  return Column(
                    children: [
                      TextField(
                        controller: searchKeyController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'সদস্য নম্বর লিখে সার্চ করুন',
                        ),
                        onChanged: (value) {
                          value = value.trim();
                          searchKeyController.text = value;
                          context.read<SearchKey>().setKey = value;
                        },
                      ),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot member = members.elementAt(index);

                            String description = 'ফোন নাম্বারঃ ${member.get('phoneNumbers').toString().split(RegExp(r"\s+")).join(' ')}';
                            if (member.get('QID').toString().isNotEmpty) {
                              description += '\nQID: ${member.get('QID').toString()}';
                            }
                            if (member.get('NID').toString().isNotEmpty) {
                              description += '\nNID: ${member.get('NID').toString()}';
                            }

                            if (member.get('passportNumber').toString().isNotEmpty) {
                              description += '\nPassport Number: ${member.get('passportNumber').toString()}';
                            }

                            List<DocumentSnapshot<Map<String, dynamic>>> loansOfMember =
                                acceptedLoans.where((loan) => loan.get('applicantMemberID').toString() == member.reference.id).toList();
                            description += '\nঋণের সংখ্যা: ${loansOfMember.length}';
                            int totalLoan =
                                loansOfMember.fold<int>(0, (previousValue, loan) => previousValue + (int.tryParse(loan.get('loanAmount').toString()) ?? 0));
                            description += '\nঋণের মোট পরিমাণঃ $totalLoan';

                            return GFCard(
                              boxFit: BoxFit.cover,
                              titlePosition: GFPosition.start,
                              title: GFListTile(
                                avatar: GFAvatar(
                                  backgroundImage: NetworkImage(member.get('profileImageLink').toString()),
                                ),
                                titleText: member.get('nameInBanglaLetters').toString(),
                                subTitleText: 'সদস্য নম্বরঃ ${member.reference.id}',
                              ),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(description),
                                  StreamBuilder<int>(
                                    stream: calculateTotalBalance(member),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return const Icon(Icons.error);
                                      }
                                      if (snapshot.hasData) {
                                        return Text('মোট সঞ্চয়ঃ ${snapshot.data}');
                                      }
                                      return const GFLoader(
                                        size: GFSize.SMALL,
                                      );
                                    },
                                  ),
                                  GFButton(
                                    fullWidthButton: true,
                                    color: GFColors.INFO,
                                    child: const Text(
                                      'বিস্তারিত তথ্য',
                                      style: TextStyle(
                                        fontFamily: 'SolaimanLipi',
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => MemberInformationScreen(member)));
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
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
      ),
    );
  }
}

class SearchKey extends ChangeNotifier {
  String _searchKey = "";

  String get getKey {
    return _searchKey;
  }

  set setKey(String newKey){
    _searchKey = newKey;
    notifyListeners();
  }
}
