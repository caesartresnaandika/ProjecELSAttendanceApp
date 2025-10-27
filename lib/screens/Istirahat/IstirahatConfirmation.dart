// lib/screens/Istirahat/IstirahatConfirmation.dart

import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:project_aplikasi_absensi_hrd_els/services/api_services.dart';
import 'package:project_aplikasi_absensi_hrd_els/services/session_manager.dart';
import 'package:project_aplikasi_absensi_hrd_els/models/user_model.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/MainMenu/MainMenu.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../SignIn/SignInPage.dart';

class IstirahatConfirmation extends StatefulWidget {
  final String imagePath;
  final bool isRestOut;

  const IstirahatConfirmation({
    Key? key,
    required this.imagePath,
    required this.isRestOut,
  }) : super(key: key);

  @override
  State<IstirahatConfirmation> createState() => _IstirahatConfirmationState();
}

class _IstirahatConfirmationState extends State<IstirahatConfirmation> {
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

  // Ganti seluruh fungsi _submitRest di IstirahatConfirmation.dart dengan ini:

  Future<void> _submitRest() async {
    if (_position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi belum siap, coba lagi.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final session = await SessionManager.getSession();
    if (session == null) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi tidak ditemukan. Silakan login ulang.')),
      );
      return;
    }

    final token = session['token'] as String;
    final user = session['user'] as User;
    final apiService = ApiService();

    // ✅ TAMBAH: Debug log untuk type
    final breakType = widget.isRestOut ? "rest_out" : "rest_in";
    print('🚀 Mengirim data istirahat: $breakType');

    try {
      bool success = await apiService.recordAttendance(
        token: token,
        type: breakType, // ✅ Gunakan variabel
        photo: widget.imagePath,
        latitude: _position!.latitude,
        longitude: _position!.longitude,
        userId: user.id,
      );

      if (mounted) setState(() => _isLoading = false);

      if (success && mounted) {
        // ✅ PERBAIKAN: Hapus session management yang tidak perlu
        // Karena data sudah diambil dari API langsung

        print('✅ Istirahat berhasil dicatat: $breakType');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isRestOut ? "Istirahat selesai!" : "Istirahat dimulai!"),
            duration: const Duration(seconds: 2),
          ),
        );

        // ✅ PERBAIKAN: Tunggu sebentar sebelum navigasi
        await Future.delayed(const Duration(milliseconds: 500));

        Navigator.pop(context, true);

      } else if (mounted) {
        print('❌ Gagal mencatat istirahat: $breakType');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mencatat istirahat! Coba lagi.')),
        );
      }
    } on SessionExpiredException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SignInPage()),
                (route) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        print('❌ Error submit istirahat: $e');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Terjadi error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final time = DateFormat('HH:mm').format(now);
    final date = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);

    return Scaffold(
      appBar: AppBar(title: Text(widget.isRestOut ? "Konfirmasi Selesai Istirahat" : "Konfirmasi Mulai Istirahat")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Pastikan data di bawah ini sudah benar sebelum konfirmasi."),
            const SizedBox(height: 24),
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
                subtitle: Text("Waktu Istirahat"),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.access_time_filled),
                title: Text(time),
                subtitle: Text("Jam Istirahat"),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.location_on),
                title: Text(_address ?? "Memuat lokasi..."),
                subtitle: Text("Lokasi Istirahat"),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitRest,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text(widget.isRestOut ? "Konfirmasi Selesai Istirahat" : "Konfirmasi Mulai Istirahat"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}