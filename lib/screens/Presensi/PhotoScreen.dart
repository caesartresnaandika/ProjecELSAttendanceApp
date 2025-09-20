import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/Presensi/ConfirmationScreen.dart';

class PhotoScreen extends StatefulWidget {
  // 1. TAMBAHKAN VARIABEL UNTUK MENYIMPAN TOKEN
  final String userId;
  final String token;

  // 2. PERBAIKI CONSTRUCTOR UNTUK MENYIMPAN TOKEN
  const PhotoScreen({
    super.key,
    required this.userId,
    required this.token, // Hapus 'String' dan tambahkan 'this.'
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
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front);

    _controller = CameraController(
      firstCamera,
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
      print(e);
    }
  }

  void _retakePicture() {
    setState(() {
      _takenImage = null;
    });
  }

  // 3. PERBAIKI FUNGSI INI UNTUK MENGIRIM TOKEN ASLI
  void _confirmPicture() {
    if (_takenImage == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmationScreen(
          imagePath: _takenImage!.path,
          userId: widget.userId, // Gunakan userId dari widget
          token: widget.token,     // Gunakan token dari widget
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && _controller != null) {
            if (_takenImage == null) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  CameraPreview(_controller!),
                  Positioned(
                    bottom: 30,
                    child: FloatingActionButton(
                      onPressed: _takePicture,
                      child: const Icon(Icons.camera_alt),
                    ),
                  ),
                ],
              );
            } else {
              return Stack(
                alignment: Alignment.center,
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
                  )
                ],
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}