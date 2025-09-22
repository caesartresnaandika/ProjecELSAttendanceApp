import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// 👇 Ganti dengan halaman riwayat ijinmu nanti
// import 'package:project_aplikasi_absensi_hrd_els/screens/Ijin/HistoryIjin.dart';

class IjinScreen extends StatefulWidget {
  const IjinScreen({Key? key}) : super(key: key);

  @override
  _IjinScreenState createState() => _IjinScreenState();
}

class _IjinScreenState extends State<IjinScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _permissionType = 'Ijin Telat';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Background soft
      appBar: AppBar(
        title: const Text(
          'Pengajuan Ijin',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6F00),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.history, color: Colors.white, size: 24),
                ),
                title: const Text(
                  "Lihat Riwayat Ijin",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                subtitle: const Text(
                  "Cek status pengajuan sebelumnya",
                  style: TextStyle(color: Colors.grey),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                onTap: () {
                  // 👇 Ganti dengan halaman riwayat ijinmu
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Fitur Riwayat Ijin akan segera hadir")),
                  );
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryIjin()));
                },
              ),
            ),

            const SizedBox(height: 20), // Padding bawah

            // 👉 CARD FORM UTAMA
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 👉 JUDUL
                    const Text(
                      "Ajukan Ijin",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 👉 JENIS IJIN
                    const Text(
                      "Jenis Ijin",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _permissionType,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF0F0F0),
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                      items: ['Ijin Telat', 'Pulang Cepat', 'Tidak Masuk', 'Ijin Lainnya']
                          .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _permissionType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // 👉 TANGGAL
                    const Text(
                      "Tanggal",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _dateController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF0F0F0),
                            suffixIcon: const Icon(Icons.calendar_today, color: Colors.orange),
                            hintText: "Pilih tanggal",
                            hintStyle: const TextStyle(color: Colors.grey),
                          ),
                          readOnly: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 👉 WAKTU (Opsional)
                    const Text(
                      "Waktu (jika diperlukan)",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectTime(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _timeController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF0F0F0),
                            suffixIcon: const Icon(Icons.access_time, color: Colors.orange),
                            hintText: "Pilih waktu",
                            hintStyle: const TextStyle(color: Colors.grey),
                          ),
                          readOnly: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 👉 ALASAN IJIN
                    const Text(
                      "Alasan Ijin",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _reasonController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF0F0F0),
                        hintText: "Tulis alasan Anda...",
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan alasan ijin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // 👉 TOMBOL AJUKAN
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitPermissionRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6F00), // Orange brand els.id
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "AJUKAN IJIN",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF6F00), // Orange brand
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF6F00), // Orange brand
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  void _submitPermissionRequest() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulasi proses loading
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengajuan ijin berhasil dikirim!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        _formKey.currentState!.reset();
        _dateController.clear();
        _timeController.clear();
        _reasonController.clear();
        setState(() {
          _permissionType = 'Ijin Telat';
        });
      });
    }
  }
}