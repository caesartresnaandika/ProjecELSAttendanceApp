// File ini berisi kelas palsu yang meniru perilaku API asli

class DummyApiService {
  // Fungsi untuk Login
  Future<bool> login(String email, String password) async {
    // Tunda selama 2 detik untuk mensimulasikan waktu loading jaringan
    await Future.delayed(const Duration(seconds: 2));

    if (email == 'test@els.id' && password == '123456') {
      print("Dummy Login Berhasil!");
      return true; // Kembalikan 'true' jika berhasil
    } else {
      print("Dummy Login Gagal!");
      return false; // Kembalikan 'false' jika gagal
    }
  }

  // Fungsi untuk Clock In
  Future<bool> clockIn(String userId, String location) async {
    // Tunda selama 1 detik
    await Future.delayed(const Duration(seconds: 1));

    // Logika dummy: Selalu anggap berhasil
    print("Dummy Clock In Berhasil untuk user: $userId di lokasi $location");
    return true;
  }

  // Fungsi untuk Clock Out
  Future<bool> clockOut(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    print("Dummy Clock Out Berhasil untuk user: $userId");
    return true;
  }
}