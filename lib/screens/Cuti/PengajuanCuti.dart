// lib/screens/Cuti/PengajuanCuti.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:project_aplikasi_absensi_hrd_els/services/api_services.dart';
import 'package:project_aplikasi_absensi_hrd_els/services/session_manager.dart';
import 'package:project_aplikasi_absensi_hrd_els/screens/Cuti/HistoryCuti.dart';

class PengajuanCuti extends StatefulWidget {
  const PengajuanCuti({super.key});

  @override
  State<PengajuanCuti> createState() => _PengajuanCutiState();

}

class _PengajuanCutiState extends State<PengajuanCuti> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  // State
  final _reasonController = TextEditingController();
  String? _selectedSubType = 'Cuti Tahunan'; // Nilai default dropdown
  DateTime? _startDate;
  DateTime? _endDate;
  File? _pickedFile;
  bool _isLoading = false;

  final List<String> _cutiSubTypes = ['Cuti Tahunan', 'Cuti Sakit', 'Cuti Melahirkan', 'Cuti Alasan Penting'];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (_startDate ?? DateTime.now()) : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null; // Reset end date jika tidak valid
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitCuti() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null || _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi tanggal dan lampiran file bukti.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final sessionData = await SessionManager.getSession();
      final token = sessionData?['token'];
      final userId = sessionData?['user']?.id;

      if (token == null || userId == null) throw Exception("Sesi tidak valid.");

      final success = await _apiService.submitLeave(
        token: token,
        userId: userId,
        type: 'cuti', // Tipe hardcoded untuk halaman ini
        subType: _selectedSubType!,
        description: _reasonController.text,
        startDate: DateFormat('yyyy-MM-dd').format(_startDate!),
        endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
        startTime: "00:00:00",
        endTime: "23:59:59",
        photoPath: _pickedFile!.path,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengajuan cuti berhasil dikirim!'), backgroundColor: Colors.green));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengirim pengajuan.'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi error: ${e.toString()}'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Pengajuan Cuti', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tombol Riwayat
            _buildHistoryButton(),
            const SizedBox(height: 24),
            // Form Card
            _buildFormCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryButton() {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryCuti())),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: const Row(
          children: [
            Icon(Icons.history, color: Colors.orange, size: 28),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Lihat Riwayat Cuti", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("Cek status pengajuan sebelumnya", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Ajukan Cuti Baru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 24),

            // --- Dropdown Jenis Cuti ---
            const Text("Jenis Cuti", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedSubType,
              items: _cutiSubTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (value) => setState(() => _selectedSubType = value),
              decoration: _inputDecoration(),
            ),
            const SizedBox(height: 16),

            // --- Tanggal Mulai & Selesai ---
            Row(
              children: [
                Expanded(child: _buildDatePickerField(isStart: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildDatePickerField(isStart: false)),
              ],
            ),
            const SizedBox(height: 16),

            // --- Alasan Cuti ---
            const Text("Alasan Cuti", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _reasonController,
              decoration: _inputDecoration(hint: "Tulis alasan Anda..."),
              maxLines: 3,
              validator: (v) => v!.isEmpty ? 'Alasan tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),

            // --- Lampiran File ---
            _buildFilePickerField(),
            const SizedBox(height: 24),

            // --- Tombol Submit ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitCuti,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Text("AJUKAN CUTI", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerField({required bool isStart}) {
    String title = isStart ? "Tanggal Mulai" : "Tanggal Selesai";
    DateTime? date = isStart ? _startDate : _endDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, isStartDate: isStart),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date == null ? 'Pilih tanggal' : DateFormat('dd/MM/yyyy').format(date)),
                const Icon(Icons.calendar_today, color: Colors.orange, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Lampiran Bukti", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickFile,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.attach_file, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _pickedFile == null ? 'Pilih file (PDF, JPG, PNG)' : _pickedFile!.path.split('/').last,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}