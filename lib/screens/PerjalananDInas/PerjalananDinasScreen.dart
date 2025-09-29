import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_aplikasi_absensi_hrd_els/utils/date_formatter.dart';

class PerjalananDinasScreen extends StatefulWidget {
  const PerjalananDinasScreen({super.key}); // 👈 Hapus userData & token

  @override
  State<PerjalananDinasScreen> createState() => _PerjalananDinasScreenState();
}

class _PerjalananDinasScreenState extends State<PerjalananDinasScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tujuanController = TextEditingController();
  final TextEditingController _alasanController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  DateTime? _tanggalBerangkat;
  DateTime? _tanggalKembali;
  File? _lampiranFile;

  bool _isLoading = false;

  @override
  void dispose() {
    _tujuanController.dispose();
    _alasanController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, {required bool isBerangkat}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange[700]!,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isBerangkat) {
          _tanggalBerangkat = picked;
          _tujuanController.text = DateFormatter.formatDate(picked);
        } else {
          _tanggalKembali = picked;
          _alasanController.text = DateFormatter.formatDate(picked);
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulasi proses pengiriman
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Surat ijin perjalanan dinas berhasil dikirim!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        _formKey.currentState!.reset();
        _tujuanController.clear();
        _alasanController.clear();
        _catatanController.clear();
        _tanggalBerangkat = null;
        _tanggalKembali = null;
        _lampiranFile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ijin Perjalanan Dinas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
            // 👉 HEADER USER (Placeholder Sementara)
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.orange.shade100,
                    child: const Text(
                      "N", // Placeholder: Inisial
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Nama Karyawan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Text(
                        "Jabatan",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 👉 FORM PERJALANAN DINAS
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Formulir Ijin Perjalanan Dinas",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 👉 TUJUAN PERJALANAN
                      const Text(
                        "Tujuan Perjalanan",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _tujuanController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          hintText: "Masukkan tujuan perjalanan...",
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan tujuan perjalanan';
                          }
                          return null;
                        },
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),

                      // 👉 TANGGAL BERANGKAT
                      const Text(
                        "Tanggal Berangkat",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectDate(context, isBerangkat: true),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _tujuanController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              suffixIcon: const Icon(Icons.calendar_today, color: Colors.orange),
                              hintText: "Pilih tanggal berangkat",
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                            readOnly: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 👉 TANGGAL KEMBALI
                      const Text(
                        "Tanggal Kembali",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectDate(context, isBerangkat: false),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _alasanController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              suffixIcon: const Icon(Icons.calendar_today, color: Colors.orange),
                              hintText: "Pilih tanggal kembali",
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                            readOnly: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 👉 ALASAN PERJALANAN
                      const Text(
                        "Alasan Perjalanan",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _alasanController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          hintText: "Masukkan alasan perjalanan...",
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan alasan perjalanan';
                          }
                          return null;
                        },
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),

                      // 👉 CATATAN TAMBAHAN
                      const Text(
                        "Catatan Tambahan",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _catatanController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          hintText: "Catatan tambahan (opsional)",
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),

                      // 👉 LAMPIRAN FILE (opsional)
                      Row(
                        children: [
                          const Icon(Icons.attach_file, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                // TODO: Implement file picker
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Fitur lampiran akan segera hadir")),
                                );
                              },
                              child: const Text("Lampirkan File (Opsional)", style: TextStyle(color: Colors.orange)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // 👉 TOMBOL AJUKAN
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6F00), // Orange brand
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "AJUKAN SURAT",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}