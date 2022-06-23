import 'package:flutter/material.dart';

import 'login_form.dart';


class LogInPageScreen extends StatefulWidget {
  const LogInPageScreen({Key? key}) : super(key: key);

  @override
  _LogInPageScreenState createState() => _LogInPageScreenState();
}

class _LogInPageScreenState extends State<LogInPageScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.asset(
                "assets/images/ahbab_logo.png",
                width: 100.0,
              ),
              const LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}



