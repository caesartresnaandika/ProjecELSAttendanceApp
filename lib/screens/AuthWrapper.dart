import 'package:flutter/material.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/MainMenu/MainMenu.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/SignIn/SignInPage.dart';
import 'package:project_aplikasi_absensi_hrd_els/services/session_manager.dart';

import 'MainPage.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Coba dapatkan sesi yang tersimpan
      future: SessionManager.getSession(),
      builder: (context, snapshot) {
        // Saat sedang loading, tampilkan spinner
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Jika ada data sesi, arahkan ke MainPage
        if (snapshot.hasData && snapshot.data != null) {
          final sessionData = snapshot.data!;
          return MainPage(
            userData: sessionData['user'],
            token: sessionData['token'],
          );
        }

        // Jika tidak ada sesi, arahkan ke SignInPage
        return const SignInPage();
      },
    );
  }
}