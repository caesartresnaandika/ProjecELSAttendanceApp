import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/Presensi/ConfirmationScreen.dart';

// LANGKAH 1: Tambahkan 'with WidgetsBindingObserver'
class PhotoScreen extends StatefulWidget {
  const PhotoScreen({super.key});

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> with WidgetsBindingObserver {
  CameraController? _controller; // Ubah menjadi nullable
  Future<void>? _initializeControllerFuture;
  XFile? _takenImage;

  @override
  void initState() {
    super.initState();
    // LANGKAH 2: Daftarkan observer
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  // LANGKAH 3: Implementasikan didChangeAppLifecycleState
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Jika controller tidak ada, atau kamera tidak terinisialisasi, jangan lakukan apa-apa
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    // Jika aplikasi tidak aktif, hentikan controller
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    }
    // Jika aplikasi kembali aktif, nyalakan lagi kameranya
    else if (state == AppLifecycleState.resumed) {
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
    // LANGKAH 4: Hapus observer saat widget dihancurkan
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

  void _confirmPicture() {
    if (_takenImage == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmationScreen(imagePath: _takenImage!.path),
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
          // Pastikan controller tidak null sebelum digunakan
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