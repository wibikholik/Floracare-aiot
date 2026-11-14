import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/auth/login.dart';
import 'package:flutter_application_1/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(child: Text('Terjadi kesalahan saat memuat aplikasi')),
            );
          }

          final token = snapshot.data?.getString('token');
          if (token != null && token.isNotEmpty) {
            return const Home();
          }
          return const Login();
        },
      ),
    );
  }
}