import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SomethingWentWrongScreen extends StatelessWidget {
  const SomethingWentWrongScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/error_to_initialize.png',
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'ইশ্‌!',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontFamily: 'Mina',
                  color: Colors.black,
                  fontSize: 30.0,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'এ্যাপটি ঠিকঠাক চালু হয়নি।\nদয়া করে বন্ধ করে আবার চালু করুন।',
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontFamily: 'Mina',
                  color: Color.fromARGB(255, 52, 116, 224),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );


  }
}

