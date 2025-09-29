import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/Presensi/ConfirmationScreen.dart';

class PhotoScreen extends StatefulWidget {
  final String userId;
  final String token;

  const PhotoScreen({
    super.key,
    required this.userId,
    required this.token,
  });

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  XFile? _takenImage;
  String? _savedImagePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
            (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first, // Fallback jika tidak ada kamera depan
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false, // Matikan audio untuk foto
      );

      _initializeControllerFuture = _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      print("Error initializing camera: $e");
      // Tampilkan pesan error ke user jika perlu
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      if (!_controller!.value.isInitialized || _controller!.value.isTakingPicture) {
        return;
      }

      final image = await _controller!.takePicture();
      final imageBytes = await image.readAsBytes();

      // 1. Simpan ke direktori internal aplikasi (PENTING untuk upload)
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'presensi_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final localPath = '${directory.path}/$fileName';
      final localFile = File(localPath);
      await localFile.writeAsBytes(imageBytes);

      // 2. Simpan ke galeri publik (Bonus untuk user)
      try {

        final result = await ImageGallerySaverPlus.saveImage(
          imageBytes,
          quality: 85,
          name: fileName,
        );

        if (result['isSuccess']) {
          print("✅ Foto berhasil disimpan ke galeri: ${result['filePath']}");
        } else {
          print("⚠️ Gagal menyimpan ke galeri. Hasil: $result");
        }
      } catch (e) {
        print("❌ Error saat simpan ke galeri: $e");
      }

      if (mounted) {
        setState(() {
          _takenImage = image;
          _savedImagePath = localPath; // Gunakan path internal untuk dikirim
        });
      }
    } catch (e, stack) {
      print("Error saat ambil foto: $e\n$stack");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto: $e')),
      );
    }
  }

  Future<void> _retakePicture() async {
    if (_savedImagePath != null) {
      final file = File(_savedImagePath!);
      if (await file.exists()) {
        await file.delete(); // Hanya hapus salinan dari direktori internal
      }
    }
    setState(() {
      _takenImage = null;
      _savedImagePath = null;
    });
  }

  void _confirmPicture() {
    if (_savedImagePath == null) return;
    Navigator.pushReplacement( // Gunakan pushReplacement agar tidak bisa kembali ke halaman foto
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmationScreen(
          imagePath: _savedImagePath!,
          userId: widget.userId,
          token: widget.token,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && _controller != null && _controller!.value.isInitialized) {
              if (_takenImage == null) {
                // Tampilan Ambil Foto
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // 👇👇👇 BAGIAN YANG DIPERBAIKI 👇👇👇
                    // Camera Preview Fullscreen
                    Center(
                      child: Transform.scale(
                        scale: 1 / (_controller!.value.aspectRatio * MediaQuery.of(context).size.aspectRatio),
                        alignment: Alignment.center,
                        child: CameraPreview(_controller!),
                      ),
                    ),
                    // 👆👆👆 AKHIR DARI BAGIAN YANG DIPERBAIKI 👆👆👆

                    // UI Overlay (bingkai, teks, tombol)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox.shrink(), // Spacer atas
                        // Bingkai Wajah
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: (MediaQuery.of(context).size.width * 0.8) * (4/3),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withOpacity(0.8),
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(200), // Oval
                          ),
                        ),
                        // Teks Petunjuk dan Tombol
                        Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.0),
                              child: Text(
                                "Posisikan wajah Anda di dalam bingkai",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  shadows: [Shadow(blurRadius: 5.0, color: Colors.black)],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 40),
                              child: FloatingActionButton(
                                onPressed: _takePicture,
                                backgroundColor: const Color(0xFFFF6F00),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 30),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                // Tampilan Konfirmasi Foto
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Tampilkan gambar yang sudah diambil dan di-flip horizontal
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: Image.file(
                        File(_savedImagePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Tombol Retake dan Confirm
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FloatingActionButton(
                            onPressed: _retakePicture,
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.replay, color: Colors.black),
                          ),
                          FloatingActionButton(
                            onPressed: _confirmPicture,
                            backgroundColor: const Color(0xFFFF6F00),
                            child: const Icon(Icons.check, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            } else {
              // Loading indicator
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

}