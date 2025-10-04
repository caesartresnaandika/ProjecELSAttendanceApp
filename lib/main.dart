import 'package:flutter/material.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/AuthWrapper.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/SignIn/SignInPage.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'screens/MainMenu/MainMenu.dart'; // Import ini tidak lagi diperlukan di sini

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  // Tambahkan inisialisasi Firebase di sini jika sudah siap
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ELS Presence',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      // Hapus MainMenu dari sini karena akan dipanggil dengan data
      routes: {
        // '/mainMenu' : (context) => const MainMenu(), // <-- HAPUS ATAU BERI KOMENTAR
      },
    );
  }
}
