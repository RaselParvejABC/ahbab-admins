import 'package:flutter/material.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
      'দুঃখিত!\nএই ফিচারটি\nশীঘ্রই আসছে!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Mina',
          fontSize: 20.0,
        ),
    )
    );
  }
}
