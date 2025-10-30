import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/pages/login_page.dart';
import 'ui/pages/media_show_page.dart';
import 'states/app_state.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => AppState(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediShow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoadingAutoLogin) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (appState.isLoggedIn) {
            return const MediaShowPage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
