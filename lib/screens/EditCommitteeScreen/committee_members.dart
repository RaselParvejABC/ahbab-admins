import 'package:flutter/foundation.dart';

class CommitteeMembers extends ChangeNotifier {
  final List<Map<String, dynamic>> _committeeMembers = [];

  add(Map<String, dynamic> member) {
    _committeeMembers.add(member);
  }

  List<Map<String, dynamic>> getList() {
    return List.from(
      _committeeMembers,
      growable: false,
    );
  }

  addAtIndex(Map<String, dynamic> member, int index) {
    _committeeMembers.insert(index, member);
  }

  Map<String, dynamic> delete(int index) {
    Map<String, dynamic> deletedOne = _committeeMembers.removeAt(index);
    return deletedOne;
  }

  deleteAll(){
    _committeeMembers.removeWhere((element) => true);
  }

  bool contains(Map<String, dynamic> member) {
    return _committeeMembers.contains(member);
  }

  notify() {
    notifyListeners();
  }
}
