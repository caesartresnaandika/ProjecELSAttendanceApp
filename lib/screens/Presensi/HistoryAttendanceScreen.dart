// lib/screens/Presensi/HistoryAttendanceScreen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_aplikasi_absensi_hrd_els/models/attendance_model.dart';
import 'package:project_aplikasi_absensi_hrd_els/services/api_services.dart';

class HistoryAttendanceScreen extends StatefulWidget {
  final String token;
  final String userId;

  const HistoryAttendanceScreen({
    super.key,
    required this.token,
    required this.userId,
  });

  @override
  State<HistoryAttendanceScreen> createState() => _HistoryAttendanceScreenState();
}

class _HistoryAttendanceScreenState extends State<HistoryAttendanceScreen> {
  List<AttendanceData> _attendanceList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceHistory();
  }

  Future<void> _fetchAttendanceHistory() async {
    try {
      // Ambil SEMUA data
      final allAttendance = await ApiService().getAttendanceHistory7Days(
        token: widget.token,
        userId: widget.userId,
      );

      // Filter hanya 7 hari terakhir di sisi Flutter
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      final filtered = allAttendance.where((record) {
        return record.datetime.isAfter(sevenDaysAgo) || record.datetime.isAtSameMomentAs(sevenDaysAgo);
      }).toList();

      if (mounted) {
        setState(() {
          _attendanceList = filtered;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat riwayat: $e')),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Presensi 7 Hari Terakhir'),
        backgroundColor: Colors.orange.shade600,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _attendanceList.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada riwayat presensi dalam 7 hari terakhir',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _attendanceList.length,
        itemBuilder: (context, index) {
          final attendance = _attendanceList[index];
          final formattedDate = DateFormat('dd MMM yyyy HH:mm').format(attendance.datetime);

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: _getIconForType(attendance.type),
              title: Text(formattedDate),
              subtitle: Text(_getTypeLabel(attendance.type)),
              trailing: attendance.image != null
                  ? IconButton(
                icon: const Icon(Icons.photo, color: Colors.blue),
                onPressed: () {
                  _showImageDialog(context, attendance.image!);
                },
              )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _getIconForType(String type) {
    switch (type) {
      case 'checkin':
        return Icon(Icons.arrow_downward, color: Colors.green);
      case 'checkout':
        return Icon(Icons.arrow_upward, color: Colors.red);
      case 'rest_in':
        return Icon(Icons.access_time, color: Colors.orange);
      case 'rest_out':
        return Icon(Icons.access_time_filled, color: Colors.orange);
      default:
        return Icon(Icons.event_note, color: Colors.grey);
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'checkin':
        return 'Jam Masuk';
      case 'checkout':
        return 'Jam Keluar';
      case 'rest_in':
        return 'Mulai Istirahat';
      case 'rest_out':
        return 'Selesai Istirahat';
      default:
        return 'Aktivitas';
    }
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('ELS_ELS:t{\$'))}';
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
                headers: {'Authorization': basicAuth, 'token': widget.token},
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
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
}