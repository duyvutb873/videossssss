import 'package:flutter/material.dart';
import '../atoms/app_logo.dart';
import '../organisms/login_form.dart';

class AuthTemplate extends StatelessWidget {
  const AuthTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                AppLogo(),
                SizedBox(height: 32),
                LoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
