import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../molecules/input_field.dart';
import '../../states/app_state.dart';
import '../pages/media_show_page.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    final state = Provider.of<AppState>(context, listen: false);
    bool ok = await state.login(_userController.text, _passController.text);
    setState(() {
      _isLoading = false;
    });
    if (ok && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MediaShowPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InputField(label: 'Tài khoản', controller: _userController),
        const SizedBox(height: 16),
        InputField(
          label: 'Mật khẩu',
          controller: _passController,
          isPassword: true,
        ),
        const SizedBox(height: 24),
        if (appState.loginError != null)
          Text(appState.loginError!, style: const TextStyle(color: Colors.red)),
        ElevatedButton(
          onPressed: _isLoading ? null : () => _submit(context),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Đăng nhập'),
        ),
      ],
    );
  }
}
