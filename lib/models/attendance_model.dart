class AttendanceData {
  final String employeeId;
  final String type;
  final DateTime datetime;
  final String? image;

  AttendanceData({
    required this.employeeId,
    required this.type,
    required this.datetime,
    this.image,
  });

  // Factory constructor untuk mengubah JSON menjadi objek AttendanceData
  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      employeeId: json['employee_id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      // Menggunakan tryParse untuk menghindari error jika format tanggal salah
      datetime: DateTime.tryParse(json['datetime'] as String? ?? '') ?? DateTime(0),
      image: json['image'] as String?,
    );
  }

  // ✅ INI BAGIAN YANG PERLU DITAMBAHKAN
  // Factory constructor untuk membuat objek default (fallback)
  factory AttendanceData.fallback() {
    return AttendanceData(
      employeeId: '',
      type: '',
      datetime: DateTime(0), // Menggunakan tahun 0 sebagai penanda data tidak valid
      image: null,
    );
  }
}