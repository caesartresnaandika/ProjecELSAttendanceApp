import 'package:flutter/material.dart';
import 'package:project_aplikasi_absensi_hrd_els/models/user_model.dart';
import 'MainMenu/MainMenu.dart';
import 'Profile/ProfilePage.dart';
import 'Kalender/KalenderScreen.dart';
class MainPage extends StatefulWidget {
  final User userData;
  final String token;
  const MainPage({super.key, required this.userData, required this.token});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  // Di dalam kelas _MainPageState di file MainPage.dart
  PreferredSizeWidget _buildProfileHeader() {
    final String userName = widget.userData.name;
    final String userPosition = widget.userData.position;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false, // Penting agar tidak ada tombol back otomatis
      titleSpacing: 23,

      // Gabungkan logo dan teks di dalam title
      title: Row(
        children: [
          const CircleAvatar(
            radius: 22,// Sedikit diperbesar agar mirip desain
            // backgroundImage: AssetImage('assets/images/icon.png'),
          ),
          const SizedBox(width : 12), // Atur jarak di sini
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("ELS.ID", style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(userName, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              Text(userPosition, style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          ),
        ],
      ),
      // Aksi (seperti notifikasi) bisa ditambahkan di sini jika perlu
      actions: [
        // IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    // Daftar halaman yang akan ditampilkan sesuai urutan di bottom nav bar
    _pages = <Widget>[
      MainMenu(userData: widget.userData, token: widget.token), // Halaman Beranda (0)
      KalenderScreen(), // Halaman Kalender (1) - GANTI INI
      ProfilePage(userData: widget.userData), // Halaman Profil (2)
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0 ? _buildProfileHeader() : null,
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Kalender'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}