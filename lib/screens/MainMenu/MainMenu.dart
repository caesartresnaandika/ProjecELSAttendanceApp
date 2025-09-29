import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_aplikasi_absensi_hrd_els/models/user_model.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/PerjalananDInas/PerjalananDinasScreen.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/Presensi/PhotoScreen.dart';
import 'package:project_aplikasi_absensi_hrd_els/services/api_services.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/Cuti/PengajuanCuti.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/Kalender/KalenderScreen.dart';
import '../Ijin/IjinScreen.dart';

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // // 👉 HEADER BRAND ELS.ID
          // _buildBrandHeader(),
          // const SizedBox(height: 24),

          // 👉 CARD ABSENSI
          _AttendanceCard(
            userData: widget.userData,
            token: widget.token,
          ),
          const SizedBox(height: 24),

          // 👉 MENU UTAMA
          _buildFavoriteMenu(),
        ],
      ),
    );
  }

  // ✅ MENU UTAMA — GUNAKAN WRAP UNTUK HINDARI OVERFLOW
  Widget _buildFavoriteMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Menu",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // 👉 GUNAKAN WRAP, BUKAN GRIDVIEW
        Wrap(
          spacing: 16, // jarak horizontal
          runSpacing: 16, // jarak vertikal
          children: [
            _buildMenuItem(Icons.card_giftcard, "Cuti", Colors.blue, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PengajuanCuti()),
              );
            }),
            _buildMenuItem(Icons.holiday_village, "Ijin", Colors.orange, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const IjinScreen()),
              );
            }),
            _buildMenuItem(Icons.card_travel_outlined, "Dinas", Colors.purple, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PerjalananDinasScreen()),
              );
            }),
            _buildMenuItem(Icons.calendar_today, "Kalender", Colors.green, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const KalenderScreen()),
              );
            }),
            _buildMenuItem(Icons.history, "Riwayat", Colors.teal, () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur Riwayat akan segera hadir')),
              );
            }),
          ],
        ),
      ],
    );
  }

  // ✅ MENU ITEM
  Widget _buildMenuItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 48 - 32) / 3, // (screen - padding - 2 spacing) / 3 kolom
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================================
// WIDGET KARTU ABSENSI (Tetap sama seperti sebelumnya)
// =======================================================================
class _AttendanceCard extends StatefulWidget {
  final User userData;
  final String token;
  const _AttendanceCard({required this.userData, required this.token});
  @override
  State<_AttendanceCard> createState() => _AttendanceCardState();
}

class _AttendanceCardState extends State<_AttendanceCard> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String _clockInTime = "--:--";
  final String _clockOutTime = "--:--";
  bool _isClockedIn = false;
  String? _attendanceId;
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
    _fetchAttendanceStatus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchAttendanceStatus() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _isClockedIn = false;
      _clockInTime = _isClockedIn ? "08:01" : "--:--";
    });
  }

  // 👇 FUNGSI BARU: Format tanggal hari ini dalam Bahasa Indonesia
  String _formatTodayDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEE, d MMM y', 'id_ID');
    return "Hari ini (${formatter.format(now)})";
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
        Text(
          _formatTodayDate(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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