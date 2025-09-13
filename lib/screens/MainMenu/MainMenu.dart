import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/Presensi/PhotoScreen.dart';

class MainMenu extends StatefulWidget {

  final Map<String, dynamic>? userData; // <-- Tambahkan tanda tanya (?)
  const MainMenu({super.key, this.userData});
  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: Colors.white,
      // LANGKAH 1: Gunakan properti appBar untuk meletakkan header
      appBar: _buildProfileHeader(),
      body: SafeArea(
        // SafeArea di sini agar konten di bawah AppBar tidak terlalu mepet ke atas
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24), // Spasi setelah AppBar
                // Bagian Kartu Absensi Utama
                _buildAttendanceCard(),
                const SizedBox(height: 24),
                // Bagian Menu Favorit
                _buildFavoriteMenu(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Fitur'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Postingan'),
          BottomNavigationBarItem(icon: Icon(Icons.workspaces_outline), label: 'Ruang Kerja'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }

  // LANGKAH 2: Ubah seluruh widget header menjadi AppBar
  PreferredSizeWidget _buildProfileHeader() {

    //GET FROM DATABASE FIREBASE
    final String userName = widget.userData?['name'] ?? 'Pengguna';
    final String userPosition = widget.userData?['position'] ?? 'Jabatan';

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0, // Menghilangkan bayangan di bawah AppBar
      // leading: untuk widget di sebelah kiri title
      leading: const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundImage: AssetImage('assets/images/profile_pic.jpg'),
        ),
      ),
      // title: untuk konten utama di tengah AppBar
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PT SMART INC",
            style: TextStyle(
                color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          Text(
            userName,
            style: TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            userPosition,
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
      // actions: untuk daftar widget di sebelah kanan
      actions: [
        // Notifikasi dengan badge angka
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_outlined,
                  color: Colors.black54),
              onPressed: () {},
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints:
                const BoxConstraints(minWidth: 16, minHeight: 16),
                child: const Text(
                  '2',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8), // Spasi di ujung kanan
      ],
    );
  }

  // WIDGET UNTUK KARTU ABSENSI
  Widget _buildAttendanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Hari ini (Fri, 04 Aug 2023)",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const Text("Shift: NO SHIFT [07:26 - 07:26]",
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTimeInfo(
                  "Jam Masuk", "07:26", Icons.arrow_downward, Colors.green),
              _buildTimeInfo(
                  "Jam Keluar", "--:--", Icons.arrow_upward, Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // Properti onPressed untuk aksi saat tombol ditekan
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PhotoScreen()),
                );
              },
              // Properti style untuk mengatur tampilan tombol
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              // Properti child untuk konten di dalam tombol (misal: teks)
              child: const Text(
                "Rekam Waktu",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Divider(height: 32),
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('assets/images/profile_pic.jpg'),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Fri, 4 Aug 2023", style: TextStyle(fontSize: 12)),
                  Text("07:26", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              const Text("Telah diproses",
                  style: TextStyle(color: Colors.green, fontSize: 12)),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text("Sembunyikan Detail ^",
                  style: TextStyle(color: Colors.grey)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTimeInfo(
      String title, String time, IconData icon, Color iconColor) {
    return Column(
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/images/avatar1.png'),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(time,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, color: iconColor, size: 16),
            const Text(" Di Lokasi",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        )
      ],
    );
  }

  // WIDGET UNTUK MENU FAVORIT
  Widget _buildFavoriteMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Menu Favorit",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        // GANTI DENGAN WRAP
        Wrap(
          spacing: 16.0, // Jarak horizontal antar item
          runSpacing: 16.0, // Jarak vertikal jika ada baris baru
          alignment: WrapAlignment.spaceBetween,
          children: [
            _buildMenuItem(Icons.card_giftcard, "Cuti"),
            _buildMenuItem(Icons.hourglass_bottom, "Lembur"),
            _buildMenuItem(Icons.receipt_long, "Slip Gaji"),
            _buildMenuItem(Icons.description, "Aktivitas Harian"),
            _buildMenuItem(Icons.message, "Pesan Real-time"),
          ],
        )
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.blue.shade800, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}