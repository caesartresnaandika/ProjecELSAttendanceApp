import 'package:flutter/material.dart';

class HistoryCuti extends StatelessWidget {
  const HistoryCuti({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Cuti'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Contoh data riwayat
          _buildHistoryItem(
            status: "Disetujui",
            date: "10 - 12 Okt 2025",
            reason: "Cuti tahunan",
            statusColor: Colors.green,
          ),
          _buildHistoryItem(
            status: "Ditolak",
            date: "20 Sep 2025",
            reason: "Acara keluarga",
            statusColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({required String status, required String date, required String reason, required Color statusColor}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        title: Text(reason, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }
}