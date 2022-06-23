import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';

Future<DocumentSnapshot> getDocumentSnapshot(String collectionPath, String documentID) async {
  return await FirebaseFirestore.instance.collection(collectionPath).doc(documentID).get(const GetOptions(source: Source.server));
}

Future<QuerySnapshot> getCollectionSnapshot(String collectionPath, String documentID) async {
  return await FirebaseFirestore.instance.collection(collectionPath).get(const GetOptions(source: Source.server));
}

Stream<QuerySnapshot> getCollectionStreamSnapshot(String collectionPath) {
  return FirebaseFirestore.instance.collection(collectionPath).snapshots();
}

Future<DocumentSnapshot> getDocumentSnapshotUsingSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String username = prefs.getString('username')!;
  return await getDocumentSnapshot('members', username);
}

dynamic getValueFromDocumentSnapshot(DocumentSnapshot snapshot, String key) {
  dynamic value;
  try {
    value = snapshot.get('key');
  } catch (error) {
    1 + 1;
  }
  return value;
}


Stream<int> calculateTotalBalance(DocumentSnapshot memberDocSnap) {
  Stream<int> totalYearlyBalance = _getYearsStream(memberDocSnap).map((event) {
    int balance = 0;
    for(Map<String, dynamic> map in event){
      if(map.isNotEmpty){
        balance += int.tryParse(map['yearlyDeposit'])??0;
      }
    }
    return balance;
  });


  Stream<int> totalMonthlyBalance = _getMonthsStream(memberDocSnap).map((event) {
    int balance = 0;
    for(Map<String, dynamic> map in event){
      if(map.isNotEmpty){
        balance += int.tryParse(map['monthlyDeposit'])??0;
      }
    }
    return balance;
  });



  return totalYearlyBalance.combineLatest<int,int>(totalMonthlyBalance, (a, b) => a+b);
}

Stream<List<Map<String, dynamic>>> _getMonthsStream(DocumentSnapshot memberDocSnap) {
  return FirebaseFirestore.instance.collection('ahbabVariables').doc('currentSession').snapshots().map((event) {
    //print('Current Session');
    int startYear = int.parse(event.get('startYear').toString());
    int endYear = int.parse(event.get('endYear').toString());
    List<int> sessionYears = [for (int i = startYear; i <= endYear; i++) i];
    var firstStream = _monthsSnapshotForYear(sessionYears.first, memberDocSnap);
    sessionYears.remove(sessionYears.first);
    return firstStream.combineLatestAll(sessionYears.map((e) => _monthsSnapshotForYear(e, memberDocSnap))).map((event) {
      //print('Combine ' + event.length.toString());
      // for(int i=0; i< event.length; i++){
      //   print(i.toString() + ' ' + event[i].length.toString());
      // }
      return event.reduce((value, element) => value + element);
    });
  }).switchLatest();
}

Stream<List<Map<String, dynamic>>> _monthsSnapshotForYear(int year, DocumentSnapshot memberDocSnap) {
  return memberDocSnap.reference.collection('savings/' + year.toString() + '/months').snapshots().map((event) {
    return event.docs.map((e) {
      Map<String, dynamic> map = Map.from(e.data());
      map['year'] = year.toString();
      map['month'] = e.reference.id;
      return map;
    }).toList();
  }).startWith([]);
}

Stream<Map<String, dynamic>> _snapshotForYear(int year, DocumentSnapshot memberDocSnap) {
  return memberDocSnap.reference.collection('savings').doc(year.toString()).snapshots().map((event) {
    Map<String, dynamic> map = Map.from(event.data() ?? {});
    return map;
  });
}

Stream<List<Map<String, dynamic>>> _getYearsStream(DocumentSnapshot memberDocSnap) {
  return FirebaseFirestore.instance.collection('ahbabVariables').doc('currentSession').snapshots().map((event) {
    //print('Current Session');
    int startYear = int.parse(event.get('startYear').toString());
    int endYear = int.parse(event.get('endYear').toString());
    List<int> sessionYears = [for (int i = startYear; i <= endYear; i++) i];
    var firstStream = _snapshotForYear(sessionYears.first, memberDocSnap);
    sessionYears.remove(sessionYears.first);
    return firstStream.combineLatestAll(sessionYears.map((e) => _snapshotForYear(e, memberDocSnap)));
  }).switchLatest();
}
