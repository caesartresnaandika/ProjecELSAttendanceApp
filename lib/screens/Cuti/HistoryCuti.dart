import 'package:flutter/material.dart';

class HistoryCuti extends StatelessWidget {
  const HistoryCuti({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Background abu-abu terang
      appBar: AppBar(
        title: const Text(
          'Riwayat Cuti',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: ListView(
          children: [
            // Data riwayat — bisa di-loop dari API nanti
            _buildHistoryItem(
              status: "Disetujui",
              date: "10 - 12 Okt 2025",
              reason: "Cuti tahunan",
              statusColor: Colors.green,
              icon: Icons.check_circle,
            ),
            const SizedBox(height: 16),
            _buildHistoryItem(
              status: "Ditolak",
              date: "20 Sep 2025",
              reason: "Acara keluarga",
              statusColor: Colors.red,
              icon: Icons.cancel,
            ),
            const SizedBox(height: 16),
            _buildHistoryItem(
              status: "Menunggu",
              date: "5 - 7 Nov 2025",
              reason: "Izin sakit",
              statusColor: Colors.orange,
              icon: Icons.hourglass_empty,
            ),
            const SizedBox(height: 60), // Padding bawah agar tidak terpotong
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem({
    required String status,
    required String date,
    required String reason,
    required Color statusColor,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👉 ICON STATUS (kiri)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // 👉 KONTEN UTAMA (alasan + tanggal)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reason,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 👉 BADGE STATUS (kanan)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: statusColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}