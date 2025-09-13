import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // --- FUNGSI OTENTIKASI ---

  /// Mencari user di koleksi 'users' berdasarkan email dan password.
  /// Mengembalikan data user jika berhasil, null jika gagal.
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final snapshot = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print("User dengan email $email tidak ditemukan.");
        return null;
      }

      final userData = snapshot.docs.first.data();
      if (userData['password'] == password) {
        print("Login berhasil untuk user: ${userData['name']}");
        // Menambahkan ID dokumen ke data yang dikembalikan
        userData['id'] = snapshot.docs.first.id;
        return userData;
      } else {
        print("Password salah.");
        return null;
      }
    } catch (e) {
      print("Error saat login: $e");
      return null;
    }
  }

  // --- FUNGSI HELPER UNTUK UPLOAD FOTO ---

  /// Mengupload file gambar ke Firebase Storage dan mengembalikan URL download-nya.
  Future<String?> _uploadPhoto(String filePath, String userId) async {
    try {
      final file = File(filePath);
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('attendance_photos').child(fileName);

      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error upload foto: $e");
      return null;
    }
  }

  // --- FUNGSI-FUNGSI PRESENSI ---

  /// Membuat dokumen absensi baru untuk user pada hari ini.
  /// Mengembalikan ID dokumen absensi jika berhasil.
  Future<String?> clockIn({
    required String userId,
    required String location,
    required String imagePath,
  }) async {
    try {
      final photoUrl = await _uploadPhoto(imagePath, userId);
      if (photoUrl == null) return null;

      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final attendanceDocId = '${userId}_$dateStr';

      await _db.collection('attendances').doc(attendanceDocId).set({
        'userId': userId,
        'date': dateStr,
        'clockIn': {
          'time': Timestamp.now(),
          'location': location,
          'photoUrl': photoUrl,
        },
        'clockOut': null,
      });
      print("Clock in berhasil untuk dokumen: $attendanceDocId");
      return attendanceDocId;
    } catch (e) {
      print("Error saat clock in: $e");
      return null;
    }
  }

  /// Mengupdate dokumen absensi yang sudah ada dengan data clock out.
  Future<bool> clockOut({
    required String attendanceDocId,
    required String userId,
    required String location,
    required String imagePath,
  }) async {
    try {
      final photoUrl = await _uploadPhoto(imagePath, userId);
      if (photoUrl == null) return false;

      await _db.collection('attendances').doc(attendanceDocId).update({
        'clockOut': {
          'time': Timestamp.now(),
          'location': location,
          'photoUrl': photoUrl,
        },
      });
      print("Clock out berhasil untuk dokumen: $attendanceDocId");
      return true;
    } catch (e) {
      print("Error saat clock out: $e");
      return false;
    }
  }

  /// Membuat dokumen baru di subcollection 'breaks' untuk memulai istirahat.
  /// Mengembalikan ID dokumen istirahat jika berhasil.
  Future<String?> startBreak({required String attendanceDocId}) async {
    try {
      final breakDoc = await _db
          .collection('attendances')
          .doc(attendanceDocId)
          .collection('breaks')
          .add({
        'start': Timestamp.now(),
        'end': null,
      });
      print("Berhasil memulai istirahat, ID: ${breakDoc.id}");
      return breakDoc.id;
    } catch (e) {
      print("Error memulai istirahat: $e");
      return null;
    }
  }

  /// Mengupdate dokumen istirahat dengan waktu selesai.
  Future<bool> endBreak({
    required String attendanceDocId,
    required String breakDocId,
  }) async {
    try {
      await _db
          .collection('attendances')
          .doc(attendanceDocId)
          .collection('breaks')
          .doc(breakDocId)
          .update({
        'end': Timestamp.now(),
      });
      print("Berhasil mengakhiri istirahat");
      return true;
    } catch (e) {
      print("Error mengakhiri istirahat: $e");
      return false;
    }
  }
}