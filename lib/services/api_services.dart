import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/attendance_model.dart';
import '../models/leave_model.dart';

class SessionExpiredException implements Exception {
  final String message;
  SessionExpiredException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  final String _baseUrl = "https://erp.els.id";
  final String _basicAuthUsername = "ELS_ELS";
  final String _basicAuthPassword = r"t{$";

  // ✅ Sumber tunggal untuk Basic Auth
  String get basicAuth => 'Basic ${base64Encode(utf8.encode('$_basicAuthUsername:$_basicAuthPassword'))}';

  // --- FUNGSI LOGIN ---
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/api/login-employee');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': basicAuth, // Menggunakan getter
    };
    final body = jsonEncode({'username': username, 'password': password});

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 200) {
          final resultsData = responseBody['results']['data'];
          final user = User.fromJson(resultsData['user']);
          final token = resultsData['token'] as String;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          return {'user': user, 'token': token};
        }
      }
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
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final datetime = formatter.format(now);

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
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    request.fields['datetime'] = formatter.format(now);

    request.headers['Authorization'] = basicAuth; // Menggunakan getter
    request.headers['token'] = token;

    final imageFile = File(photo);
    if (!await imageFile.exists()) {
      print("DEBUG: File does not exist!");
      return false;
    }
    request.files.add(await http.MultipartFile.fromPath('photo', photo));

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final responseBody = jsonDecode(response.body);

      if (responseBody['status'] == 400 && (responseBody['message']?.contains('kedaluwarsa') ?? false)) {
        throw SessionExpiredException('Sesi telah kedaluwarsa, silakan login kembali.');
      }
      if (response.statusCode == 200 && responseBody['status'] == 200) {
        return true;
      }
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

    // ❌ Variabel lokal 'basicAuth' DIHAPUS dari sini

    // ✅ Langsung menggunakan getter 'basicAuth'
    request.headers['Authorization'] = basicAuth;
    request.headers['token'] = token;

    File imageFile = File(imagePath);
    if (!await imageFile.exists()) {
      print("ERROR: File gambar tidak ditemukan di path: $imagePath");
      return false;
    }
    request.files.add(await http.MultipartFile.fromPath('photo', imagePath));

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['status'] == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print("ERROR: Gagal mengirim request upload foto: $e");
      return false;
    }
  }

  // --- FUNGSI AMBIL DATA PRESENSI ---
  Future<List<AttendanceData>> getAttendanceData({
    required String token,
    required String userId,
  }) async {
    final url = Uri.parse('$_baseUrl/api/attend/data');

    final headers = {
      'Authorization': basicAuth,
      'token': token,
      'Content-Type': 'application/json',
    };

    //GET dengan BODY (bukan query parameters)
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final body = jsonEncode({
      "limit": 50, // Tambah limit untuk dapat lebih banyak data
      "page": 1,
      "sort": "datetime",
      "dir": "DESC", // Pastikan DESC bukan DISC
      "filter": [
        {
          "type": "string",
          "property": "employee_id",
          "operator": "eq",
          "value": userId
        },
        {
          "type": "string",
          "property": "datetime",
          "operator": "like",
          "value": today
        }
      ]
    });

    try {
      //Menggunakan http.Request untuk GET dengan body
      final request = http.Request('GET', url);
      request.headers.addAll(headers);
      request.body = body;

      print('📡 GET Attendance Request:');
      print('URL: $url');
      print('Headers: $headers');
      print('Body: $body');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 GET Attendance Response:');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (responseBody['status'] == 400 &&
          (responseBody['message'] == 'sesi telah kedaluwarsa.' ||
              responseBody['message'] == 'Sesi tidak ditemukan.')) {
        throw SessionExpiredException('Sesi telah kedaluwarsa, silakan login kembali.');
      }

      if (response.statusCode == 200 && responseBody['status'] == 200) {
        // ✅ KEMBALI KE CARA LAMA: Akses results.data
        if (responseBody['results']['data'] != null && responseBody['results']['data'] is List) {
          List<dynamic> resultsData = responseBody['results']['data'];

          print('📊 Data attendance diterima: ${resultsData.length} records');

          List<AttendanceData> attendanceList = resultsData.map((json) => AttendanceData.fromJson(json)).toList();

          print('✅ Berhasil parsing ${attendanceList.length} records');
          return attendanceList;
        }

        print('ℹ️ Tidak ada data attendance untuk employee $userId pada tanggal $today');
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

  /// Mengajukan Cuti, Ijin, atau Test ke server.
  Future<bool> submitLeave({
    required String token,
    required String userId,
    required String type,
    required String subType,
    required String startDate,
    required String endDate,
    required String startTime,
    required String endTime,
    required String description,
    required String photoPath,
  }) async {
    if (photoPath.isEmpty) {
      print("❌ ERROR: Path foto tidak boleh kosong.");
      return false;
    }
    final imageFile = File(photoPath);
    if (!await imageFile.exists()) {
      print("❌ ERROR: File bukti tidak ditemukan di path: $photoPath");
      return false;
    }

    final url = Uri.parse('$_baseUrl/api/leave/add');
    var request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = basicAuth; // Menggunakan getter
    request.headers['token'] = token;

    request.fields['employee_id'] = userId;
    request.fields['type'] = type;
    request.fields['sub_type'] = subType;
    request.fields['start_date'] = startDate;
    request.fields['end_date'] = endDate;
    request.fields['start_time'] = startTime;
    request.fields['end_time'] = endTime;
    request.fields['description'] = description;

    request.files.add(await http.MultipartFile.fromPath('photo', photoPath));

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['status'] == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("❌ ERROR: Gagal mengirim request pengajuan: $e");
      return false;
    }
  }
}