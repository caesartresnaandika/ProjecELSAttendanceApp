import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
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
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.front,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller!.initialize();
    if (mounted) setState(() {});
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
      final image = await _controller!.takePicture();
      setState(() {
        _takenImage = image;
      });
    } catch (e) {
      print("Error saat ambil foto: $e");
    }
  }

  void _retakePicture() {
    setState(() {
      _takenImage = null;
    });
  }

  void _confirmPicture() {
    if (_takenImage == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmationScreen(
          imagePath: _takenImage!.path,
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
        child: Container(
          color: Colors.black,
          child: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && _controller != null) {
                if (_takenImage == null) {
                  return Stack(
                    children: [
                      // 👇 CAMERA FULL SCREEN
                      CameraPreview(_controller!),

                      // 👇 OVERLAY: BINGKAI + TEKS + TOMBOL
                      Column(
                        children: [
                          // Spacer atas (biar bingkai tidak nempel ke atas)
                          const Spacer(flex: 1),

                          // 👉 BINGKAI WAJAH (FULL WIDTH)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: AspectRatio(
                              aspectRatio: 3 / 4, // Rasio portrait
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.7),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),

                          // 👉 TEKS PETUNJUK
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              "Posisikan wajah Anda di dalam bingkai",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          // 👉 TOMBOL KAMERA (DI BAWAH)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 40),
                            child: FloatingActionButton(
                              onPressed: _takePicture,
                              backgroundColor: const Color(0xFFFF6F00), // Orange brand
                              child: const Icon(Icons.camera_alt, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Stack(
                    children: [
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: Image.file(File(_takenImage!.path)),
                      ),
                      Positioned(
                        bottom: 30,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FloatingActionButton(
                              onPressed: _retakePicture,
                              backgroundColor: Colors.red,
                              child: const Icon(Icons.close, color: Colors.white),
                            ),
                            FloatingActionButton(
                              onPressed: _confirmPicture,
                              backgroundColor: Colors.green,
                              child: const Icon(Icons.check, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}