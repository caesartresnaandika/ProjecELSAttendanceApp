import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project_aplikasi_absensi_hrd_els/models/user_model.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/Presensi/PhotoScreen.dart';
import 'package:project_aplikasi_absensi_hrd_els/services/api_services.dart';
// Import halaman-halaman baru
import 'package:project_aplikasi_absensi_hrd_els/screens/Cuti/PengajuanCuti.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/Kalender/KalenderScreen.dart';
import '../Ijin/IjinScreen.dart';

// MainMenu sekarang hanya fokus pada konten Beranda
class MainMenu extends StatefulWidget {
  final User userData;
  final String token;
  const MainMenu({super.key, required this.userData, required this.token});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    // Tidak ada Scaffold, karena sudah diatur oleh MainPage
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AttendanceCard(
              userData: widget.userData,
              token: widget.token, // Teruskan token ke _AttendanceCard
            ),
            const SizedBox(height: 24),
            _buildFavoriteMenu(),
          ],
        ),
      ),
    );
  }

  // Method-method helper untuk konten tetap ada di sini
  Widget _buildFavoriteMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Menu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMenuItem(Icons.card_giftcard, "Cuti", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PengajuanCuti()),
              );
            }),
            _buildMenuItem(Icons.holiday_village, "Ijin", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => IjinScreen()),
              );
            }),
            _buildMenuItem(Icons.calendar_today, "Kalender", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => KalenderScreen()),
              );
            }),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMenuItem(Icons.card_travel_outlined, "Dinas", () {
              // TODO: Tambahkan navigasi ke halaman Perjalanan Dinas
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fitur Perjalanan Dinas akan segera hadir')),
              );
            }),
            _buildMenuItem(Icons.history, "Riwayat", () {
              // TODO: Tambahkan navigasi ke halaman Riwayat
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fitur Riwayat akan segera hadir')),
              );
            }),
            _buildMenuItem(Icons.settings, "Pengaturan", () {
              // TODO: Tambahkan navigasi ke halaman Pengaturan
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fitur Pengaturan akan segera hadir')),
              );
            }),
          ],
        )
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: _getIconColor(label), size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getIconColor(String label) {
    switch (label) {
      case 'Cuti':
        return Colors.blue[700]!;
      case 'Ijin':
        return Colors.orange[700]!;
      case 'Kalender':
        return Colors.green[700]!;
      case 'Dinas':
        return Colors.purple[700]!;
      case 'Riwayat':
        return Colors.teal[700]!;
      case 'Pengaturan':
        return Colors.grey[700]!;
      default:
        return Colors.blue.shade800;
    }
  }
}

// =======================================================================
// WIDGET KARTU ABSENSI (Tetap sama seperti sebelumnya)
// =======================================================================
class _AttendanceCard extends StatefulWidget {
  final User userData;
  final String token; // Variabel untuk menerima token
  const _AttendanceCard({required this.userData, required this.token});
  @override
  State<_AttendanceCard> createState() => _AttendanceCardState();
}

class _AttendanceCardState extends State<_AttendanceCard> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true; // Untuk menampilkan loading di awal
  String _clockInTime = "--:--";
  String _clockOutTime = "--:--";
  bool _isClockedIn = false;
  String? _attendanceId; // Untuk menyimpan ID absensi hari ini
  final PageController _pageController = PageController();
  int _selectedTab = 0;
  bool _isOnBreak = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page?.round() != _selectedTab) {
        setState(() {
          _selectedTab = _pageController.page!.round();
        });
      }
    });
    // Panggil fungsi untuk cek status saat halaman dibuka
    _fetchAttendanceStatus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengambil status absensi terbaru dari server
  Future<void> _fetchAttendanceStatus() async {
    setState(() {
      _isLoading = true;
    });

    // Simulasi loading
    await Future.delayed(const Duration(seconds: 1));

    // NANTI GANTI DENGAN DATA ASLI DARI API
    // final status = await _apiService.getAttendanceStatus(widget.token);
    // if (status != null) { ... }

    // Data dummy untuk sementara
    setState(() {
      _isLoading = false;
      _isClockedIn = false; // Coba ubah jadi 'true' untuk melihat tampilan setelah clock in
      _clockInTime = _isClockedIn ? "08:01" : "--:--";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAnimatedTabBar(),
          const SizedBox(height: 16),
          SizedBox(
            height: 230,
            child: PageView(
              controller: _pageController,
              children: [
                _buildPresenceContent(),
                _buildBreakContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTabBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _selectedTab == 0
                ? 0
                : MediaQuery.of(context).size.width / 2 - 32,
            right: _selectedTab == 1
                ? 0
                : MediaQuery.of(context).size.width / 2 - 32,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]),
            ),
          ),
          Row(
            children: [
              Expanded(child: _buildTabItem("Presensi", 0)),
              Expanded(child: _buildTabItem("Istirahat", 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    bool isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      },
      child: Container(
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Text(
          title,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.orange.shade600 : Colors.grey.shade500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPresenceContent() {
    if (_isLoading) {
      return const SizedBox(
          height: 230,
          child: Center(child: CircularProgressIndicator()));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Hari ini (Jum, 19 Sep 2025)",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const Text("Shift: -",
            style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _TimeInfoColumn(
                title: "Jam Masuk",
                time: _clockInTime,
                status: "Di Lokasi",
                icon: Icons.arrow_downward,
                iconColor: Colors.green),
            _TimeInfoColumn(
                title: "Jam Keluar",
                time: _clockOutTime,
                status: "Di Lokasi",
                icon: Icons.arrow_upward,
                iconColor: Colors.red),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (!_isClockedIn) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PhotoScreen(
                          userId: widget.userData.id,
                          token: widget.token,
                        )));
              } else {
                // TODO: Buat alur clock out
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: _isClockedIn ? Colors.red : Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: Text(_isClockedIn ? "Clock Out" : "Rekam Waktu",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakContent() {
    return Column(
      children: [
        const Text("Catat waktu istirahat Anda di sini.",
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _isOnBreak = !_isOnBreak;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isOnBreak ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(_isOnBreak ? "Akhiri Istirahat" : "Mulai Istirahat",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

// WIDGET HELPER UNTUK INFO JAM
class _TimeInfoColumn extends StatelessWidget {
  final String title;
  final String time;
  final String status;
  final IconData icon;
  final Color iconColor;

  const _TimeInfoColumn({
    required this.title,
    required this.time,
    required this.status,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 4),
        Text(time,
            style:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 4),
            Text(status,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        )
      ],
    );
  }
}