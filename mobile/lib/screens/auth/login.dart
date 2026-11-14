import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/helper/constant.dart';
import 'package:flutter_application_1/methods/api.dart';
import 'package:flutter_application_1/screens/auth/register.dart';
import 'package:flutter_application_1/screens/home.dart';
import 'package:flutter_application_1/widget/input_field.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  // Login dengan email & password
  void loginUser() async {
    if (email.text.trim().isEmpty || password.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password wajib diisi!')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final data = {
      "email": email.text.trim(),
      "password": password.text.trim(),
    };

    try {
      final result = await API().postRequest(route: '/login', data: data);
      final response = jsonDecode(result.body);

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });

      if (result.statusCode == 200 && response['status'] == 200) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        await preferences.setInt('user_id', response['user']['id']);
        await preferences.setString('name', response['user']['name'] ?? '');
        await preferences.setString('email', response['user']['email'] ?? '');
        await preferences.setString('token', response['token']);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Login berhasil!')),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Login gagal')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan koneksi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = deviceWidth(context);
    double height = deviceHeight(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.04),

              // Header logo & nama aplikasi
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.local_florist,
                        size: 64,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'FloraCare',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Monitoring & Perawatan Tanaman Hias Otomatis',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.04),

              // Form email & password
              const Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 6),
              InputField(
                width: width,
                controller: email,
                hintText: "Masukkan email Anda",
              ),
              const SizedBox(height: 16),
              const Text(
                'Password',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 6),
              InputField(
                width: width,
                controller: password,
                hintText: "Masukkan password Anda",
                isObscure: true,
              ),
              const SizedBox(height: 24),

              // Tombol masuk
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isLoading ? null : loginUser,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Link ke halaman daftar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Belum punya akun?",
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const Register(),
                        ),
                      );
                    },
                    child: Text(
                      "Daftar Sekarang",
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}