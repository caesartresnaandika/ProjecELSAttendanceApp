import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class ConfirmationScreen extends StatefulWidget {
  final String imagePath;
  const ConfirmationScreen({super.key, required this.imagePath});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  String? _address;
  Position?   _position;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Di dalam kelas _ConfirmationScreenState

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true; // Mulai loading
    });

    // 1. Cek apakah layanan lokasi aktif
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _address = "Layanan lokasi tidak aktif.";
        _isLoading = false;
      });
      return;
    }

    // 2. Cek dan minta izin lokasi
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _address = "Izin lokasi ditolak.";
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _address = "Izin lokasi ditolak permanen. Aktifkan di pengaturan HP.";
        _isLoading = false;
      });
      return;
    }

    // 3. Jika izin sudah diberikan, baru ambil lokasi
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      setState(() {
        _position = position;
        _address = placemarks.isNotEmpty
            ? "${placemarks[0].street}, ${placemarks[0].locality}"
            : "Lokasi tidak ditemukan";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _address = "Terjadi error saat mengambil lokasi.";
        _isLoading = false;
      });
    }
  }

  void _submitPresence() {
    // Di sini kamu akan memanggil API Service-mu
    // dummyApiService.clockIn(userId, _position, widget.imagePath);

    // Tampilkan pesan sukses
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kehadiran berhasil dicatat!')),
    );

    // Kembali ke halaman Beranda (MainMenu) dan hapus semua halaman di atasnya
    Navigator.popUntil(context, (route) => route.isFirst);
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
          // Wadah untuk mengatur ukuran dan posisi bingkai gambar
            SizedBox(
              height: 240, // Tinggi bingkai (bisa disesuaikan)
              width: 180,  // Lebar bingkai (proporsi ~4x6)
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: Image.file(
                    File(widget.imagePath),
                    // BoxFit.contain akan memastikan seluruh gambar muat di dalam bingkai tanpa terpotong
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