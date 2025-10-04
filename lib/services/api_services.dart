  import 'dart:convert';
  import 'dart:io';
  import 'package:http/http.dart' as http;
  import 'package:intl/intl.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import '../models/user_model.dart';
  import '../models/attendance_model.dart';
  
  class SessionExpiredException implements Exception {
    final String message;
    SessionExpiredException(this.message);
    @override
    String toString() => message;
  }
  
  class ApiService {
    // ✅ Perbaikan: Hapus spasi di akhir URL
    final String _baseUrl = "https://erp.els.id";
    final String _basicAuthUsername = "ELS_ELS";
    final String _basicAuthPassword = r"t{$";
  
    // --- FUNGSI LOGIN ---
    Future<Map<String, dynamic>?> login(String username, String password) async {
      final url = Uri.parse('$_baseUrl/api/login-employee');
  
      // ✅ TAMBAHKAN LOGIKA BASIC AUTH DI SINI
      final String basicAuth = 'Basic ${base64Encode(utf8.encode('$_basicAuthUsername:$_basicAuthPassword'))}';
  
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': basicAuth, // ✅ TAMBAHKAN HEADER INI
      };
  
      final body = jsonEncode({
        'username': username,
        'password': password,
      });
  
      print("DEBUG: Mengirim request ke: $url");
      print("DEBUG: Body yang dikirim: $body");
      print("DEBUG: Headers yang dikirim: $headers"); // Tambahan log untuk verifikasi
  
      try {
        final response = await http.post(url, headers: headers, body: body);
  
        print("DEBUG: Menerima status code: ${response.statusCode}");
        print("DEBUG: Isi respons: ${response.body}");
  
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);
  
          // Periksa status dari dalam JSON respons
          if (responseBody['status'] == 200) {
            final resultsData = responseBody['results']['data'];
            final user = User.fromJson(resultsData['user']);
            final token = resultsData['token'] as String;
  
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('auth_token', token);
  
            return {'user': user, 'token': token};
          }
        }
        // Jika status code bukan 200 atau status di body bukan 200
        return null;
      } catch (e) {
        print("Terjadi error koneksi: $e");
        return null;
      }
    }
  
  
    // --- FUNGSI DUMP UNTUK DEBUGGING REQUEST PRESENSI ---
    void dumpAttendanceRequest({
      required String token,
      required String type,
      required String photo,
      required double latitude,
      required double longitude,
      required String userId,
    }) {
      final now = DateTime.now().toUtc().add(const Duration(hours: 7));
      final roundedWib = DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second);
      final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      final datetime = formatter.format(roundedWib);
  
  
      final basicAuth = 'Basic ${base64Encode(utf8.encode('$_basicAuthUsername:$_basicAuthPassword'))}';
  
      print('===== DUMP: POST ATTENDANCE REQUEST =====');
      print('URL: $_baseUrl/api/attend/add');
      print('Method: POST');
      print('Headers:');
      print('  Authorization: $basicAuth');
      print('  token: $token');
      print('Form Data:');
      print('  employee_id: "$userId"');
      print('  latitude: "$latitude"');
      print('  longitude: "$longitude"');
      print('  type: "$type"');
      print('  datetime: "$datetime"');
      print('File:');
      print('  Field: "photo"');
      print('  Path: "$photo"');
  
      final fileExists = File(photo).existsSync();
      print('  Exists: ${fileExists ? "✅ Yes" : "❌ No"}');
      print('=========================================');
    }
  
    // --- FUNGSI REKAM WAKTU ---
    Future<bool> recordAttendance({
      required String token,
      required String type,
      required String photo,
      required double latitude,
      required double longitude,
      required String userId,
    }) async {
      final url = Uri.parse('$_baseUrl/api/attend/add');
      var request = http.MultipartRequest('POST', url);
  
      request.fields['employee_id'] = userId;
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      request.fields['type'] = type;
  
      final now = DateTime.now().toUtc().add(const Duration(hours: 7));
      final roundedWib = DateTime(now.year, now.month, now.day, now.hour, now.minute);
      final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      request.fields['datetime'] = formatter.format(roundedWib);
  
      String basicAuth = 'Basic ${base64Encode(utf8.encode('$_basicAuthUsername:$_basicAuthPassword'))}';
      request.headers['Authorization'] = basicAuth;
      request.headers['token'] = token;
  
      final imageFile = File(photo);
      if (await imageFile.exists()) {
        print("DEBUG: File exists, size: ${await imageFile.length()} bytes");
        final multipartFile = await http.MultipartFile.fromPath('photo', photo);
        request.files.add(multipartFile);
        print("DEBUG: File added to request: ${multipartFile.filename}");
      } else {
        print("DEBUG: File does not exist!");
        return false;
      }
  
      dumpAttendanceRequest(
        token: token,
        type: type,
        photo: photo,
        latitude: latitude,
        longitude: longitude,
        userId: userId,
      );
  
      try {
        print("DEBUG: Mengirim request presensi...");
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
  
        print("DEBUG: Status Code: ${response.statusCode}");
        print("DEBUG: Response Body: ${response.body}");
  
        final responseBody = jsonDecode(response.body);
  
        if (responseBody['status'] == 400 &&
            (responseBody['message'] == 'sesi telah kedaluwarsa.' ||
                responseBody['message'] == 'Sesi tidak ditemukan.')) {
          throw SessionExpiredException('Sesi telah kedaluwarsa, silakan login kembali.');
        }
  
        if (response.statusCode == 200 && responseBody['status'] == 200) {
          print("✅ presensi berhasil direkam!");
          return true;
        }
  
        print("❌ Gagal merekam presensi. Pesan: ${responseBody['message']}");
        return false;
  
      } catch (e) {
        if (e is SessionExpiredException) rethrow;
        print("ERROR: Gagal mengirim request: $e");
        return false;
      }
    }
  
    // --- FUNGSI UPLOAD PROFILE IMAGE ---
    Future<bool> uploadProfileImage({
      required String token,
      required String imagePath,
    }) async {
      final url = Uri.parse('$_baseUrl/api/user/update-profile-image');
      var request = http.MultipartRequest('POST', url);
  
      String basicAuth = 'Basic ${base64Encode(utf8.encode('$_basicAuthUsername:$_basicAuthPassword'))}';
      request.headers['Authorization'] = basicAuth;
      request.headers['token'] = token;
  
      File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        request.files.add(await http.MultipartFile.fromPath('photo', imagePath));
      } else {
        print("ERROR: File gambar tidak ditemukan di path: $imagePath");
        return false;
      }
  
      try {
        print("DEBUG: Mengirim request upload foto profil...");
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
  
        print("DEBUG: Status Code: ${response.statusCode}");
        print("DEBUG: Response Body: ${response.body}");
  
        final responseBody = jsonDecode(response.body);
  
        if (response.statusCode == 200 && responseBody['status'] == 200) {
          print("✅ Foto profil berhasil diupload!");
          return true;
        }
  
        print("❌ Gagal upload foto profil. Pesan: ${responseBody['message']}");
        return false;
  
      } catch (e) {
        print("ERROR: Gagal mengirim request upload foto: $e");
        return false;
      }
    }
  
    // --- FUNGSI AMBIL DATA PRESENSI ---
  // File: lib/services/api_services.dart
  
    Future<List<AttendanceData>> getAttendanceData({
      required String token,
      required String userId,
    }) async {
      final url = Uri.parse('$_baseUrl/api/attend/data');
  
      final String basicAuth = 'Basic ${base64Encode(utf8.encode('$_basicAuthUsername:$_basicAuthPassword'))}';
      final headers = {
        'Authorization': basicAuth,
        'token': token,
        'Content-Type': 'application/json',
      };
  
      // ✅ DIUBAH: Struktur body disesuaikan agar sama persis dengan Postman
      final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  
      final body = jsonEncode({
        "limit": 10,
        "page": 1,
        "sort": "datetime",
        "dir": "DISC",
        "filter": [ // Pastikan ini adalah array tunggal, bukan array di dalam array
          {"type": "string", "property": "employee_id", "operator": "eq", "value": userId},
          {"type": "string", "property": "datetime", "operator": "like", "value": today}
        ]
      });
  
      try {
        // Menggunakan http.Request untuk mengirim GET dengan body
        final request = http.Request('GET', url);
        request.headers.addAll(headers);
        request.body = body;
  
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
  
        print("DEBUG: Status Code GET Attendance: ${response.statusCode}");
        print("DEBUG: Response Body GET Attendance: ${response.body}");
  
        final responseBody = jsonDecode(response.body);
  
        if (responseBody['status'] == 400 &&
            (responseBody['message'] == 'sesi telah kedaluwarsa.' ||
                responseBody['message'] == 'Sesi tidak ditemukan.')) {
          throw SessionExpiredException('Sesi telah kedaluwarsa, silakan login kembali.');
        }
  
        if (response.statusCode == 200 && responseBody['status'] == 200) {
          if (responseBody['results']['data'] != null && responseBody['results']['data'] is List) {
            List<dynamic> resultsData = responseBody['results']['data'];
            return resultsData.map((json) => AttendanceData.fromJson(json)).toList();
          }
          return [];
        }
  
        print("❌ Gagal mengambil data presensi. Pesan: ${responseBody['message']}");
        return [];
  
      } catch (e) {
        if (e is SessionExpiredException) rethrow;
        print("ERROR: Gagal mengambil data presensi: $e");
        return [];
      }
    }
  }