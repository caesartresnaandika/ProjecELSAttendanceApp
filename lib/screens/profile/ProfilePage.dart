import 'package:flutter/material.dart';
import 'package:project_aplikasi_absensi_hrd_els/models/user_model.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/SignIn/SignInPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatelessWidget {
  // LANGKAH 1: Letakkan variabel dan constructor di bagian PALING ATAS kelas
  final User userData;
  const ProfilePage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          _buildProfileHeader(
            name: userData.name,
            position: userData.position,
          ),
          const Divider(),
          _buildProfileMenuItem(
            icon: Icons.person_outline,
            text: "My Profile",
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.lock_outline,
            text: "Change Password",
            onTap: () {},
          ),
          const Divider(),
          _buildProfileMenuItem(
            icon: Icons.logout,
            text: "Logout",
            textColor: Colors.red,
            onTap: () => _handleLogout(context), // Panggil method helper
          ),
        ],
      ),
    );
  }

  // LANGKAH 2: Letakkan SEMUA method helper di bawah method build

  Future<void> _handleLogout(BuildContext context) async {
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun Anda?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true && context.mounted) {
      // Hapus sesi pengguna jika menggunakan shared_preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
            (Route<dynamic> route) => false,
      );
    }
  }

  Widget _buildProfileHeader({required String name, required String position}) {
    final String initials =
    name.isNotEmpty ? name.substring(0, 1).toUpperCase() : "?";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.orange.shade100,
            child: Text(
              initials,
              style: TextStyle(color: Colors.orange.shade800, fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi, $name",
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                position,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color textColor = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(text, style: TextStyle(color: textColor)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}