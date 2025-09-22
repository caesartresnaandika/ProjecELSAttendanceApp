import 'package:flutter/material.dart';
import 'package:project_aplikasi_absensi_hrd_els/models/user_model.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/SignIn/SignInPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatelessWidget {
  final User userData;
  const ProfilePage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Background soft
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          // 👉 HEADER PROFIL
          _buildProfileHeader(
            name: userData.name,
            position: userData.position, email: '',
            // email: userData.email ?? "email@example.com",
          ),

          const SizedBox(height: 24),

          // 👉 MENU UTAMA
          _buildSectionHeader("Pengaturan Akun"),
          _buildProfileMenuItem(
            icon: Icons.person_outline,
            text: "Edit Profil",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur Edit Profil akan segera hadir")),
              );
            },
          ),
          _buildProfileMenuItem(
            icon: Icons.lock_outline,
            text: "Ubah Kata Sandi",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur Ubah Kata Sandi akan segera hadir")),
              );
            },
          ),
          _buildProfileMenuItem(
            icon: Icons.notifications_none,
            text: "Notifikasi",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur Notifikasi akan segera hadir")),
              );
            },
          ),

          const Divider(height: 1, indent: 16, endIndent: 16),

          // 👉 MENU BANTUAN
          _buildSectionHeader("Bantuan & Info"),
          _buildProfileMenuItem(
            icon: Icons.help_outline,
            text: "Bantuan",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur Bantuan akan segera hadir")),
              );
            },
          ),
          _buildProfileMenuItem(
            icon: Icons.info_outline,
            text: "Tentang Aplikasi",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur Tentang Aplikasi akan segera hadir")),
              );
            },
          ),

          const Divider(height: 1, indent: 16, endIndent: 16),

          // 👉 TOMBOL LOGOUT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handleLogout(context),
                icon: const Icon(Icons.logout, size: 20),
                label: const Text(
                  "Keluar dari Akun",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50, // Background soft
                  foregroundColor: Colors.red.shade700, // Text merah
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40), // Padding bawah
        ],
      ),
    );
  }

  // ✅ Method Helper: Logout
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
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFFF6F00), // Orange brand
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true && context.mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
            (Route<dynamic> route) => false,
      );
    }
  }

  // ✅ Method Helper: Header Profil
  Widget _buildProfileHeader({
    required String name,
    required String position,
    required String email,
  }) {
    final String initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : "?";

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFFF6F00).withOpacity(0.15),
            child: Text(
              initials,
              style: const TextStyle(
                color: Color(0xFFFF6F00),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo, $name",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  position,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Method Helper: Section Header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  // ✅ Method Helper: Menu Item
  Widget _buildProfileMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.grey.shade700, size: 20),
      ),
      title: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}