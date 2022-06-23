import 'dart:convert';

import 'package:ahbabadmin/auth/cryptography.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

Future<String> checkUsernamePassword(String username, String password) async {
  DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('admins').doc(username).get();
  if (!userDoc.exists) {
    return "এই ইউজারনেমের কোনো এডমিন নেই!";
  }
  if (userDoc.get('passwordHash').toString() != getSHA256Hash(password)) {
    return "পাসওয়ার্ড ভুল লিখেছেন!";
  }
  String sessionKey = sha256.convert(utf8.encode(username + password + DateTime.now().toString())).toString();

  List<String> sessionKeys = [];

  try {
    sessionKeys = (userDoc.get('sessionKeys') as List).map((e) => e as String).toList();
  } catch (error) {
    1 + 1; //Nothing to do
  }

  sessionKeys.add(sessionKey);

  try {
    userDoc.reference.update({
      'sessionKeys': sessionKeys,
    });
  } catch (error) {
    return 'ইন্টারনেট সংযোগ চেক করে\nআবার চেষ্টা করুন।';
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('username', username);
  prefs.setString('name', userDoc.get('name'));
  prefs.setString('sessionKey', sessionKey);
  return "";
}

Future<String> checkSessionKey() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('username') &&
      prefs.getString('username') != null &&
      prefs.containsKey('sessionKey') &&
      prefs.getString('sessionKey') != null) {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('admins').doc(prefs.getString('username')).get();

    try {
      userDoc.get('sessionKeys');
    } catch (error) {
      return 'Show Login Screen';
    }

    if (((userDoc.get('sessionKeys') as List).map((e) => e as String)).contains(prefs.getString('sessionKey'))) {
      return "";
    }
  }
  return "Show Login Screen";
}

Future logOut() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('admins').doc(prefs.getString('username')).get();

  try {
    userDoc.get('sessionKeys');
  } catch (error) {
    return 'Show Login Screen';
  }
  await userDoc.reference.update({
    'sessionKeys': ((userDoc.get('sessionKeys') as List).map((e) => e as String)).where((element) => element != prefs.getString('sessionKey')).toList(),
  });

  await prefs.clear();

  return;
}
