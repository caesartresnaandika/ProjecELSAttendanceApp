import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/user_model.dart';

class SessionExpiredException implements Exception {
  final String message;
  SessionExpiredException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  final String _baseUrl = "https://erp.els.id";
  final String _basicAuthUsername = "ELS_ELS";
  final String _basicAuthPassword = "t{\$";

  // --- FUNGSI LOGIN ---
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/api/login-employee');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final body = jsonEncode({
      'username': username,
      'password': password,
    });

    print("DEBUG: Mengirim request ke: $url");
    print("DEBUG: Body yang dikirim: $body");

    try {
      final response = await http.post(url, headers: headers, body: body);

      print("DEBUG: Menerima status code: ${response.statusCode}");
      print("DEBUG: Isi respons: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 200) {
          final resultsData = responseBody['results']['data'];
          final user = User.fromJson(resultsData['user']);
          final token = resultsData['token'];
          return {'user': user, 'token': token};
        }
      }
      return null;
    } catch (e) {
      print("Terjadi error koneksi: $e");
      return null;
    }
  }

  // --- FUNGSI REKAM WAKTU YANG DIPERBAIKI ---
  // --- FUNGSI REKAM WAKTU YANG DIPERBAIKI ---
  Future<bool> recordAttendance({
    required String token,
    required String type,
    required String imagePath,
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse('$_baseUrl/api/attend/add');
    var request = http.MultipartRequest('POST', url);

    // --- DEBUG: Print informasi request ---
    print("DEBUG: URL: $url");
    print("DEBUG: Token: $token");
    print("DEBUG: Type: $type");
    print("DEBUG: Latitude: $latitude");
    print("DEBUG: Longitude: $longitude");
    print("DEBUG: Image Path: $imagePath");

    // --- BAGIAN YANG DIPERBAIKI ---
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$_basicAuthUsername:$_basicAuthPassword'))}';
    print("DEBUG: Basic Auth: $basicAuth");

    // 1. Tambahkan SEMUA otentikasi ke HEADERS
    request.headers['Authorization'] = basicAuth;
    request.headers['token'] = token; // <-- TOKEN HARUS DI SINI

    // 2. FIELDS hanya untuk data, BUKAN token
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    request.fields['type'] = type;
    request.fields['datetime'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // --- DEBUG: Print semua headers dan fields ---
    print("DEBUG: Request Headers: ${request.headers}");
    print("DEBUG: Request Fields: ${request.fields}");

    // Cek apakah file gambar ada
    File imageFile = File(imagePath);
    if (await imageFile.exists()) {
      print("DEBUG: File image exists, size: ${await imageFile.length()} bytes");
      request.files.add(await http.MultipartFile.fromPath('photo', imagePath));
      print("DEBUG: Photo file added to request");
    } else {
      print("DEBUG: ERROR - File image does not exist!");
      return false;
    }

    try {
      print("DEBUG: Sending request...");
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // --- DEBUG: Print response details ---
      print("DEBUG: Response Status Code: ${response.statusCode}");
      print("DEBUG: Response Headers: ${response.headers}");
      print("DEBUG: Full Response Body: ${response.body}");

      final responseBody = jsonDecode(response.body);

      if (responseBody['status'] == 400 && (responseBody['message'] == 'sesi telah kedaluwarsa.' || responseBody['message'] == 'Sesi tidak ditemukan.')) {
        print("DEBUG: Session expired detected");
        throw SessionExpiredException('Sesi telah kedaluwarsa, silakan login kembali.');
      }

      if (response.statusCode == 200 && responseBody['status'] == 200) {
        print("DEBUG: Attendance recorded successfully");
        return true;
      }

      print("DEBUG: Failed to record attendance. Status: ${responseBody['status']}, Message: ${responseBody['message']}");
      return false;

    } catch (e) {
      if (e is SessionExpiredException) {
        print("DEBUG: SessionExpiredException thrown");
        rethrow;
      }
      print("DEBUG: Error during request: $e");
      print("DEBUG: Error type: ${e.runtimeType}");
      return false;
    }
  }
}