import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:project_aplikasi_absensi_hrd_els/services/api_services.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/SignIn/SignInPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfirmationScreen extends StatefulWidget {
  final String imagePath;
  final String userId;
  final String token;

  const ConfirmationScreen({
    super.key,
    required this.imagePath,
    required this.userId,
    required this.token,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  String? _address;
  Position? _position;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Layanan lokasi tidak aktif.');
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
          throw Exception('Izin lokasi ditolak.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak permanen.');
      }
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (mounted) {
        setState(() {
          _position = position;
          _address = placemarks.isNotEmpty ? "${placemarks[0].street}, ${placemarks[0].locality}" : "Alamat tidak ditemukan";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _address = "Gagal mendapatkan lokasi.";
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // FUNGSI SUBMIT PRESENSI YANG SUDAH TERHUBUNG KE API
  void _submitPresence() async {
    if (_position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi belum siap, coba lagi.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final apiService = ApiService();

    try {
      bool success = await apiService.recordAttendance(
        token: widget.token, // Gunakan token asli dari halaman sebelumnya
        type: 'checkin',      // Untuk tipe presensi
        photo: widget.imagePath,
        latitude: _position!.latitude,
        longitude: _position!.longitude,
        userId: widget.userId,
      );

      if (mounted) setState(() => _isLoading = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kehadiran berhasil dicatat!')),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mencatat kehadiran! Coba lagi.')),
        );
      }
    } on SessionExpiredException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const SignInPage()), (route) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final time = DateFormat('HH:mm').format(now);
    final date = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);

    return Scaffold(
      appBar: AppBar(title: const Text("Konfirmasi Kehadiran")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Pastikan data di bawah ini sudah benar sebelum konfirmasi."),
            const SizedBox(height: 24),
            // Menampilkan foto yang diambil
            SizedBox(
              height: 240,
              width: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text(date),
                subtitle: Text("Waktu Presensi"),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.access_time_filled),
                title: Text(time),
                subtitle: Text("Jam Presensi"),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.location_on),
                title: Text(_address ?? "Memuat lokasi..."),
                subtitle: Text("Lokasi Presensi"),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitPresence,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text("Konfirmasi & Kembali ke Beranda"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}