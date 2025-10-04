import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_aplikasi_absensi_hrd_els/models/attendance_model.dart';
import 'package:project_aplikasi_absensi_hrd_els/models/user_model.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/PerjalananDInas/PerjalananDinasScreen.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/Presensi/PhotoScreen.dart';
import 'package:project_aplikasi_absensi_hrd_els/services/api_services.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/Cuti/PengajuanCuti.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/Kalender/KalenderScreen.dart';
import '../Ijin/IjinScreen.dart';
import 'package:project_aplikasi_absensi_hrd_els/services/session_manager.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/SignIn/SignInPage.dart';
import 'dart:convert';
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
            _AttendanceCard(
              key: _attendanceCardKey,
              userData: widget.userData,
              token: widget.token,
            ),
            const SizedBox(height: 24),
            _buildFavoriteMenu(),
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
                Icons.card_travel_outlined, "Dinas", Colors.purple, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PerjalananDinasScreen()),
              );
            }),
            _buildMenuItem(Icons.calendar_today, "Kalender", Colors.green, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const KalenderScreen()),
              );
            }),
            _buildMenuItem(Icons.history, "Riwayat", Colors.teal, () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Fitur Riwayat akan segera hadir')),
              );
            }),
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
// WIDGET KARTU ABSENSI (BAGIAN YANG DIPERBARUI TOTAL)
// =======================================================================
class _AttendanceCard extends StatefulWidget {
  final User userData;
  final String token;
  const _AttendanceCard(
      {super.key, required this.userData, required this.token});
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
    if (mounted) setState(() => _isLoading = true);

    try {
      List<AttendanceData> attendanceList = await _apiService.getAttendanceData(
        token: widget.token,
        userId: widget.userData.id,
      );

      // Reset semua state sebelum diisi ulang
      String? checkin, checkout, restIn, restOut;
      String? checkinImageUrl, checkoutImageUrl, restInImageUrl, restOutImageUrl;

      if (attendanceList.isNotEmpty) {
        attendanceList.sort((a, b) => a.datetime.compareTo(b.datetime));

        // Ambil data check-in
        final firstCheckin = attendanceList.firstWhere(
                (att) => att.type == 'checkin',
            orElse: () => AttendanceData.fallback());
        if (firstCheckin.datetime.year != 0) {
          checkin = DateFormat('HH:mm').format(firstCheckin.datetime);
          checkinImageUrl = firstCheckin.image;
        }

        // Ambil data check-out
        final lastCheckout = attendanceList.lastWhere(
                (att) => att.type == 'checkout',
            orElse: () => AttendanceData.fallback());
        if (lastCheckout.datetime.year != 0) {
          checkout = DateFormat('HH:mm').format(lastCheckout.datetime);
          checkoutImageUrl = lastCheckout.image;
        }

        // Ambil data istirahat masuk
        final firstRestIn = attendanceList.firstWhere(
                (att) => att.type == 'rest_in',
            orElse: () => AttendanceData.fallback());
        if (firstRestIn.datetime.year != 0) {
          restIn = DateFormat('HH:mm').format(firstRestIn.datetime);
          restInImageUrl = firstRestIn.image;
        }

        // Ambil data istirahat keluar
        final lastRestOut = attendanceList.lastWhere(
                (att) => att.type == 'rest_out',
            orElse: () => AttendanceData.fallback());
        if (lastRestOut.datetime.year != 0) {
          restOut = DateFormat('HH:mm').format(lastRestOut.datetime);
          restOutImageUrl = lastRestOut.image;
        }
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
      }
    } on SessionExpiredException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), duration: const Duration(seconds: 3)),
      );
      await _handleLogout();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error memuat data: ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateToPhotoScreen(String attendanceType) async {
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
    if (result == true && mounted) await fetchAttendanceStatus();
  }

  Future<void> _navigateToBreakScreen(bool isRestOut) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IstirahatPhotoScreen(isRestOut: isRestOut),
      ),
    );
    if (result == true && mounted) await fetchAttendanceStatus();
  }

  String _formatTodayDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEE, d MMM y', 'id_ID');
    return "Hari ini (${formatter.format(now)})";
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    // ✅ header untuk gambar
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('ELS_ELS:t{\$'))}';
    final Map<String, String> headers = {
      'Authorization': basicAuth,
      'token': widget.token, // Menggunakan token dari state
    };
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 500),
              child: Image.network(
                imageUrl,
                headers: headers,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Icon(Icons.broken_image,
                          size: 50, color: Colors.red),
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
      return const Center(child: CircularProgressIndicator());
    }

    final bool hasClockedIn = _clockInTime != null;
    final bool isAttendanceComplete = hasClockedIn && _clockOutTime != null;

    String buttonText;
    Color buttonColor;
    VoidCallback? onPressedAction;

    if (isAttendanceComplete) {
      buttonText = 'Presensi Lengkap';
      buttonColor = Colors.grey;
      onPressedAction = null;
    } else if (hasClockedIn) {
      buttonText = 'Rekam Jam Keluar';
      buttonColor = Colors.red;
      onPressedAction = () => _navigateToPhotoScreen('checkout');
    } else {
      buttonText = 'Rekam Jam Masuk';
      buttonColor = Colors.orange;
      onPressedAction = () => _navigateToPhotoScreen('checkin');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_formatTodayDate(),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const Text("Shift: -",
            style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: Text(buttonText,
                style: const TextStyle(fontWeight: FontWeight.bold)),
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

    final String startBreakTime = _breakInTime ?? "--:--";
    final String endBreakTime = _breakOutTime ?? "--:--";

    String buttonText;
    Color buttonColor;
    VoidCallback? onPressedAction;

    final bool hasStartedBreak = _breakInTime != null;
    final bool hasEndedBreak = _breakOutTime != null;

    if (hasStartedBreak && !hasEndedBreak) {
      buttonText = "Selesai Istirahat";
      buttonColor = Colors.red;
      onPressedAction = () => _navigateToBreakScreen(true); // isRestOut = true
    } else if (hasStartedBreak && hasEndedBreak) {
      buttonText = "Istirahat Selesai";
      buttonColor = Colors.grey;
      onPressedAction = null;
    } else {
      buttonText = "Mulai Istirahat";
      buttonColor = Colors.orange;
      onPressedAction = () => _navigateToBreakScreen(false); // isRestOut = false
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_formatTodayDate(),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const Text("Shift: -",
            style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _TimeInfoColumn(
              title: "Jam Mulai Istirahat",
              time: startBreakTime,
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
              time: endBreakTime,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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
    this.onIconTap, required this.token,
  });

  @override
  Widget build(BuildContext context) {
    bool hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    final String basicAuth = 'Basic ${base64Encode(utf8.encode('ELS_ELS:t{\$'))}';
    final Map<String, String> headers = {
      'Authorization': basicAuth,
      'token': token, // Menggunakan token dari state
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
            Text(status,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        )
      ],
    );
  }
}