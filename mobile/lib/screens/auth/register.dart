import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/helper/constant.dart';
import 'package:flutter_application_1/methods/api.dart';
import 'package:flutter_application_1/screens/auth/login.dart';
import 'package:flutter_application_1/screens/home.dart';
import 'package:flutter_application_1/widget/input_field.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => RegisterState();
}

class RegisterState extends State<Register> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  // Mengambil pesan error pertama dari validasi Laravel (status 422)
  String _pesanError(dynamic response, String bawaan) {
    if (response is Map) {
      final errors = response['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final pertama = errors.values.first;
        if (pertama is List && pertama.isNotEmpty) {
          return pertama.first.toString();
        }
      }
      if (response['message'] != null) {
        return response['message'].toString();
      }
    }
    return bawaan;
  }

  void registerUser() async {
    if (name.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        password.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom wajib diisi!')),
      );
      return;
    }

    if (password.text.trim().length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 8 karakter')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final data = {
      "name": name.text.trim(),
      "email": email.text.trim(),
      "password": password.text.trim(),
    };

    try {
      final result = await API().postRequest(route: '/register', data: data);
      final response = jsonDecode(result.body);

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });

      // Backend mengembalikan 201 saat registrasi berhasil
      final berhasil = (result.statusCode == 200 || result.statusCode == 201) &&
          (response['status'] == 200 || response['status'] == 201);

      if (berhasil) {
        if (response['token'] != null) {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          await preferences.setInt('user_id', response['user']['id']);
          await preferences.setString('name', response['user']['name'] ?? '');
          await preferences.setString('email', response['user']['email'] ?? '');
          await preferences.setString('token', response['token']);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(response['message'] ?? 'Registrasi berhasil!')),
          );

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Home()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  response['message'] ?? 'Registrasi berhasil! Silakan login.'),
            ),
          );

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Login()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_pesanError(response, 'Registrasi gagal'))),
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

              // Header logo & judul
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
                      'Buat Akun Baru',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Bergabung dengan FloraCare',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.04),

              // Nama lengkap
              const Text(
                'Nama Lengkap',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 6),
              InputField(
                width: width,
                controller: name,
                hintText: "Masukkan nama lengkap Anda",
              ),
              const SizedBox(height: 16),

              // Email
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

              // Password
              const Text(
                'Password',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 6),
              InputField(
                width: width,
                controller: password,
                hintText: "Masukkan password Anda (min. 8 karakter)",
                isObscure: true,
              ),
              const SizedBox(height: 24),

              // Tombol daftar
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
                  onPressed: isLoading ? null : registerUser,
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
                          'Daftar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Link kembali ke login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sudah punya akun?",
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    },
                    child: Text(
                      "Masuk Sekarang",
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