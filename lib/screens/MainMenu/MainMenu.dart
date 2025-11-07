import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_aplikasi_absensi_hrd_els/models/attendance_model.dart';
import 'package:project_aplikasi_absensi_hrd_els/models/user_model.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/PerjalananDInas/PerjalananDinasScreen.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/Presensi/PhotoScreen.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/Presensi/HistoryAttendanceScreen.dart';
import 'package:project_aplikasi_absensi_hrd_els/services/api_services.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/Cuti/PengajuanCuti.dart';
import '../Ijin/IjinScreen.dart';
import 'package:project_aplikasi_absensi_hrd_els/services/session_manager.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/SignIn/SignInPage.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/Istirahat/IstirahatPhotoScreen.dart';

class MainMenu extends StatefulWidget {
  final User userData;
  final String token;
  const MainMenu({super.key, required this.userData, required this.token});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final GlobalKey<_AttendanceCardState> _attendanceCardKey =
  GlobalKey<_AttendanceCardState>();

  Future<void> _startAttendance(String attendanceType) async {
    try {
      print('🚀 Memulai presensi: $attendanceType');
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoScreen(
            userId: widget.userData.id,
            token: widget.token,
            attendanceType: attendanceType,
          ),
        ),
      );

      print('🔄 Hasil dari PhotoScreen: $result');

      if (result == true && mounted) {
        print('🔄 Memperbarui status kehadiran...');
        await _attendanceCardKey.currentState?.fetchAttendanceStatus();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data kehadiran diperbarui!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error dalam _startAttendance: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _startBreak(bool isRestOut) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IstirahatPhotoScreen(isRestOut: isRestOut),
      ),
    );
    if (result == true && mounted) {
      await _attendanceCardKey.currentState?.fetchAttendanceStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await _attendanceCardKey.currentState?.fetchAttendanceStatus();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📋 KARTU PRESENSI
            _AttendanceCard(
              key: _attendanceCardKey,
              userData: widget.userData,
              token: widget.token,
              onAttendancePressed: _startAttendance,
              onBreakPressed: _startBreak,
            ),
            const SizedBox(height: 24),

            // 🔝 MENU RIWAYAT PRESENSI DI BAWAH KARTU DAN DI ATAS TULISAN MENU
            _buildHistoryMenuItem(),

            const SizedBox(height: 24),

            // 📁 MENU FAVORIT (HANYA 3)
            _buildFavoriteMenu(),
          ],
        ),
      ),
    );
  }

  // 🔝 MENU RIWAYAT PRESENSI — DITEMPATKAN DI BAWAH KARTU DAN DI ATAS TULISAN MENU
  Widget _buildHistoryMenuItem() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryAttendanceScreen(
              token: widget.token,
              userId: widget.userData.id,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.history, color: Colors.teal, size: 28),
            ),
            const SizedBox(width: 12),
            Text(
              "Riwayat Presensi",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        Wrap(
          spacing: 16,
          runSpacing: 16,
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
            _buildMenuItem(
              Icons.card_travel_outlined,
              "Perjalanan Dinas",
              Colors.purple,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PerjalananDinasScreen()),
                );
              },
            ),
            // ❌ Menu Kalender dihapus karena sudah ada di navigation bar
          ],
        ),
      ],
    );
  }

  Widget _buildMenuItem(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 48 - 32) / 3,
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
// WIDGET KARTU ABSENSI (DIPERBAIKI DENGAN CALLBACK)
// =======================================================================
class _AttendanceCard extends StatefulWidget {
  final User userData;
  final String token;
  final Future<void> Function(String attendanceType) onAttendancePressed;
  final Future<void> Function(bool isRestOut) onBreakPressed;

  const _AttendanceCard({
    super.key,
    required this.userData,
    required this.token,
    required this.onAttendancePressed,
    required this.onBreakPressed,
  });

  @override
  State<_AttendanceCard> createState() => _AttendanceCardState();
}

class _AttendanceCardState extends State<_AttendanceCard> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;

  // State untuk Presensi
  String? _clockInTime;
  String? _clockOutTime;
  String? _clockInImageUrl;
  String? _clockOutImageUrl;

  // State untuk Istirahat
  String? _breakInTime;
  String? _breakOutTime;
  String? _breakInImageUrl;
  String? _breakOutImageUrl;

  final PageController _pageController = PageController();
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page?.round() != _selectedTab) {
        if (mounted) {
          setState(() {
            _selectedTab = _pageController.page!.round();
          });
        }
      }
    });
    fetchAttendanceStatus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    await SessionManager.clearSession();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SignInPage()),
            (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> fetchAttendanceStatus() async {
    print('🔄 fetchAttendanceStatus dipanggil');

    if (mounted) setState(() => _isLoading = true);

    try {
      List<AttendanceData> attendanceList = await _apiService.getAttendanceData(
        token: widget.token,
        userId: widget.userData.id,
      );

      print('📊 Data attendance diterima: ${attendanceList.length} records');

      // Debug: print semua data yang diterima dengan detail
      print('🔍 DETAIL DATA ATTENDANCE:');
      for (var attendance in attendanceList) {
        print('   📝 Type: ${attendance.type} | Time: ${DateFormat('HH:mm').format(attendance.datetime)} | Date: ${attendance.datetime} | Employee: ${attendance.employeeId}');
      }

      String? checkin, checkout, restIn, restOut;
      String? checkinImageUrl, checkoutImageUrl, restInImageUrl, restOutImageUrl;

      if (attendanceList.isNotEmpty) {
        // Urutkan dari yang terlama ke terbaru
        attendanceList.sort((a, b) => a.datetime.compareTo(b.datetime));

        print('🕒 Data setelah diurutkan:');
        for (var att in attendanceList) {
          print('   ${att.type} - ${DateFormat('HH:mm').format(att.datetime)}');
        }

        // ✅ PERBAIKAN: Debug setiap pencarian data

        // Cari checkin pertama
        final checkins = attendanceList.where((att) => att.type == 'checkin').toList();
        print('🔍 Checkins found: ${checkins.length}');
        if (checkins.isNotEmpty) {
          final firstCheckin = checkins.first;
          checkin = DateFormat('HH:mm').format(firstCheckin.datetime);
          checkinImageUrl = firstCheckin.image;
          print('✅ Checkin ditemukan: $checkin');
        } else {
          print('ℹ️ Tidak ada data checkin');
        }

        // Cari checkout terakhir
        final checkouts = attendanceList.where((att) => att.type == 'checkout').toList();
        print('🔍 Checkouts found: ${checkouts.length}');
        if (checkouts.isNotEmpty) {
          final lastCheckout = checkouts.last;
          checkout = DateFormat('HH:mm').format(lastCheckout.datetime);
          checkoutImageUrl = lastCheckout.image;
          print('✅ Checkout ditemukan: $checkout');
        } else {
          print('ℹ️ Tidak ada data checkout');
        }

        // Cari rest_in pertama
        final restIns = attendanceList.where((att) => att.type == 'rest_in').toList();
        print('🔍 Rest Ins found: ${restIns.length}');
        if (restIns.isNotEmpty) {
          final firstRestIn = restIns.first;
          restIn = DateFormat('HH:mm').format(firstRestIn.datetime);
          restInImageUrl = firstRestIn.image;
          print('✅ Rest In ditemukan: $restIn');
        } else {
          print('ℹ️ Tidak ada data rest_in');
        }

        // Cari rest_out terakhir
        final restOuts = attendanceList.where((att) => att.type == 'rest_out').toList();
        print('🔍 Rest Outs found: ${restOuts.length}');
        if (restOuts.isNotEmpty) {
          final lastRestOut = restOuts.last;
          restOut = DateFormat('HH:mm').format(lastRestOut.datetime);
          restOutImageUrl = lastRestOut.image;
          print('✅ Rest Out ditemukan: $restOut');
        } else {
          print('ℹ️ Tidak ada data rest_out');
        }
      } else {
        print('📭 Tidak ada data attendance untuk hari ini');
      }

      if (mounted) {
        setState(() {
          _clockInTime = checkin;
          _clockOutTime = checkout;
          _clockInImageUrl = checkinImageUrl;
          _clockOutImageUrl = checkoutImageUrl;

          _breakInTime = restIn;
          _breakOutTime = restOut;
          _breakInImageUrl = restInImageUrl;
          _breakOutImageUrl = restOutImageUrl;
        });
        print('✅ State diperbarui - Clock In: $_clockInTime, Clock Out: $_clockOutTime');
        print('✅ State diperbarui - Break In: $_breakInTime, Break Out: $_breakOutTime');

        // ✅ PERBAIKAN: Debug final state
        print('🎯 FINAL STATE:');
        print('   Presensi - In: $_clockInTime, Out: $_clockOutTime');
        print('   Istirahat - In: $_breakInTime, Out: $_breakOutTime');
      }
    } on SessionExpiredException catch (e) {
      print('❌ Session expired: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), duration: const Duration(seconds: 3)),
      );
      await _handleLogout();
    } catch (e) {
      print('❌ Error fetchAttendanceStatus: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error memuat data: ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  String _formatTodayDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEE, d MMM y', 'id_ID');
    return "Hari ini (${formatter.format(now)})";
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('ELS_ELS:t{\$'))}';
    final Map<String, String> headers = {
      'Authorization': basicAuth,
      'token': widget.token,
    };
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 500),
              child: Image.network(
                imageUrl,
                headers: headers,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Icon(Icons.broken_image, size: 50, color: Colors.red),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
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
                : (MediaQuery.of(context).size.width / 2) - 32,
            right: _selectedTab == 1
                ? 0
                : (MediaQuery.of(context).size.width / 2) - 32,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
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
      return const Center(child: CircularProgressIndicator());
    }

    final bool hasClockedIn = _clockInTime != null;
    final bool hasClockedOut = _clockOutTime != null;

    String buttonText;
    Color buttonColor;
    VoidCallback? onPressedAction;

    if (hasClockedOut) {
      buttonText = 'Presensi Lengkap';
      buttonColor = Colors.grey;
      onPressedAction = null;
    } else if (hasClockedIn) {
      buttonText = 'Rekam Jam Keluar';
      buttonColor = Colors.red;
      onPressedAction = () => widget.onAttendancePressed('checkout');
    } else {
      buttonText = 'Rekam Jam Masuk';
      buttonColor = Colors.orange;
      onPressedAction = () => widget.onAttendancePressed('checkin');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ PERBAIKAN: Hapus debug info dari UI final
        Text(_formatTodayDate(), style: TextStyle(fontWeight: FontWeight.bold)),
        const Text("Shift: -", style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _TimeInfoColumn(
              title: "Jam Masuk",
              time: _clockInTime ?? "--:--",
              status: "Di Lokasi",
              icon: Icons.arrow_downward,
              iconColor: Colors.green,
              imageUrl: _clockInImageUrl,
              onIconTap: _clockInImageUrl != null
                  ? () => _showImageDialog(context, _clockInImageUrl!)
                  : null,
              token: widget.token,
            ),
            _TimeInfoColumn(
              title: "Jam Keluar",
              time: _clockOutTime ?? "--:--",
              status: "Di Lokasi",
              icon: Icons.arrow_upward,
              iconColor: Colors.red,
              imageUrl: _clockOutImageUrl,
              onIconTap: _clockOutImageUrl != null
                  ? () => _showImageDialog(context, _clockOutImageUrl!)
                  : null,
              token: widget.token,
            ),
          ],
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPressedAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(buttonText, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBreakContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final bool hasStartedBreak = _breakInTime != null;
    final bool hasEndedBreak = _breakOutTime != null;

    String buttonText;
    Color buttonColor;
    VoidCallback? onPressedAction;

    if (hasStartedBreak && !hasEndedBreak) {
      buttonText = "Selesai Istirahat";
      buttonColor = Colors.red;
      onPressedAction = () => widget.onBreakPressed(true);
    } else if (hasStartedBreak && hasEndedBreak) {
      buttonText = "Istirahat Selesai";
      buttonColor = Colors.grey;
      onPressedAction = null;
    } else {
      buttonText = "Mulai Istirahat";
      buttonColor = Colors.orange;
      onPressedAction = () => widget.onBreakPressed(false);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_formatTodayDate(), style: const TextStyle(fontWeight: FontWeight.bold)),
        const Text("Shift: -", style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _TimeInfoColumn(
              title: "Jam Mulai Istirahat",
              time: _breakInTime ?? "--:--",
              status: "Di Lokasi",
              icon: Icons.arrow_downward,
              iconColor: Colors.green,
              imageUrl: _breakInImageUrl,
              onIconTap: _breakInImageUrl != null
                  ? () => _showImageDialog(context, _breakInImageUrl!)
                  : null,
              token: widget.token,
            ),
            _TimeInfoColumn(
              title: "Jam Selesai Istirahat",
              time: _breakOutTime ?? "--:--",
              status: "Di Lokasi",
              icon: Icons.arrow_upward,
              iconColor: Colors.red,
              imageUrl: _breakOutImageUrl,
              onIconTap: _breakOutImageUrl != null
                  ? () => _showImageDialog(context, _breakOutImageUrl!)
                  : null,
              token: widget.token,
            ),
          ],
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPressedAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// =======================================================================
// WIDGET HELPER UNTUK INFO JAM (DENGAN FOTO)
// =======================================================================
class _TimeInfoColumn extends StatelessWidget {
  final String title;
  final String time;
  final String status;
  final IconData icon;
  final Color iconColor;
  final String? imageUrl;
  final VoidCallback? onIconTap;
  final String token;

  const _TimeInfoColumn({
    required this.title,
    required this.time,
    required this.status,
    required this.icon,
    required this.iconColor,
    this.imageUrl,
    this.onIconTap,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    bool hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    final String basicAuth = 'Basic ${base64Encode(utf8.encode('ELS_ELS:t{\$'))}';
    final Map<String, String> headers = {
      'Authorization': basicAuth,
      'token': token,
    };

    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (hasImage)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: onIconTap,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: NetworkImage(imageUrl!, headers: headers),
                    onBackgroundImageError: (exception, stackTrace) {},
                  ),
                ),
              ),
            Text(
              time,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 4),
            Text(status, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        )
      ],
    );
  }

}

