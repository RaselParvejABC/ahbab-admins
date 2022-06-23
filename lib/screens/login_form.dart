import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../auth/auth.dart';

// Define a custom Form widget.
class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  LoginFormState createState() => LoginFormState();
}

// Define a corresponding State class.
// This class holds data related to the form.
class LoginFormState extends State<LoginForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              icon: Icon(FontAwesome5Solid.user_shield),
              hintText: 'এডমিন ইউজারনেম',
            ),
            // The validator receives the text that the user has entered.
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'এডমিন ইউজারনেম লিখেননি!';
              }
              return null;
            },
          ),
          TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                icon: Icon(FontAwesome5Solid.key),
                hintText: 'পাসওয়ার্ড',
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'পাসওয়ার্ড লিখেননি!';
                }
                return null;
              }),
          const SizedBox(
            height: 16.0,
          ),
          ElevatedButton(
            child: const Text('লগ ইন'),
            onPressed: () async {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    dismissDirection: DismissDirection.none,
                    duration: Duration(
                      hours: 1, //Something Long Enough
                    ),
                    backgroundColor: Colors.white,
                    content: LinearProgressIndicator(
                      color: Colors.blue,
                      value: null,
                    ),
                  ),
                );
                String? errorMessage = await checkUsernamePassword(_usernameController.text.trim(), _passwordController.text);
                ScaffoldMessenger.of(context).clearSnackBars();
                if (errorMessage != "") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(
                        errorMessage,
                        style: const TextStyle(
                          fontFamily: 'SolaimanLipi',
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                } else {
                  Navigator.pushReplacementNamed(context, 'RestrictedScreen');
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
