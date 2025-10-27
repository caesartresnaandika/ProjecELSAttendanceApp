// lib/screens/PerjalananDinas/PerjalananDinasScreen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:project_aplikasi_absensi_hrd_els/models/user_model.dart';
import 'package:project_aplikasi_absensi_hrd_els/services/api_services.dart';
import 'package:project_aplikasi_absensi_hrd_els/services/session_manager.dart';

class PerjalananDinasScreen extends StatefulWidget {
  const PerjalananDinasScreen({super.key});

  @override
  State<PerjalananDinasScreen> createState() => _PerjalananDinasScreenState();
}

class _PerjalananDinasScreenState extends State<PerjalananDinasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  // State
  final _tujuanController = TextEditingController();
  final _alasanController = TextEditingController();
  final _catatanController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  File? _pickedFile;
  bool _isLoading = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final session = await SessionManager.getSession();
    setState(() {
      _currentUser = session?['user'];
    });
  }

  @override
  void dispose() {
    _tujuanController.dispose();
    _alasanController.dispose();
    _catatanController.dispose();
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
            _endDate = null;
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
      setState(() => _pickedFile = File(result.files.single.path!));
    }
  }

  Future<void> _submitDinas() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null || _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi tujuan, tanggal, dan lampiran file.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final sessionData = await SessionManager.getSession();
      final token = sessionData?['token'];
      final userId = sessionData?['user']?.id;
      if (token == null || userId == null) throw Exception("Sesi tidak valid.");

      String description = "Alasan: ${_alasanController.text}";
      if (_catatanController.text.isNotEmpty) {
        description += ". Catatan: ${_catatanController.text}";
      }

      final success = await _apiService.submitLeave(
        token: token,
        userId: userId,
        type: 'dinas',
        subType: _tujuanController.text, // Tujuan perjalanan sebagai sub_type
        description: description,
        startDate: DateFormat('yyyy-MM-dd').format(_startDate!),
        endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
        startTime: "00:00:00",
        endTime: "23:59:59",
        photoPath: _pickedFile!.path,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengajuan dinas berhasil dikirim!'), backgroundColor: Colors.green));
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
        title: const Text('Ijin Perjalanan Dinas', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildUserHeader(),
            const SizedBox(height: 24),
            _buildFormCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    String initials = _currentUser?.name.isNotEmpty == true
        ? _currentUser!.name.split(' ').map((e) => e[0]).take(2).join()
        : "U";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.orange.shade100,
            child: Text(initials, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_currentUser?.name ?? 'Nama Karyawan', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(_currentUser?.position ?? 'Jabatan', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
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
            const Text("Formulir Ijin Perjalanan Dinas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 24),

            const Text("Tujuan Perjalanan", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tujuanController,
              decoration: _inputDecoration(hint: "Contoh: Kunjungan Klien di Jakarta"),
              validator: (v) => v!.isEmpty ? 'Tujuan tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildDatePickerField(isStart: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildDatePickerField(isStart: false)),
              ],
            ),
            const SizedBox(height: 16),

            const Text("Alasan Perjalanan", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _alasanController,
              decoration: _inputDecoration(hint: "Tulis alasan perjalanan..."),
              maxLines: 3,
              validator: (v) => v!.isEmpty ? 'Alasan tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),

            const Text("Catatan Tambahan (Opsional)", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _catatanController,
              decoration: _inputDecoration(hint: "Tulis catatan tambahan..."),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            _buildFilePickerField(),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitDinas,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Text("AJUKAN SURAT", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widgets for date picker and file picker (can be extracted to separate file later)
  Widget _buildDatePickerField({required bool isStart}) {
    String title = isStart ? "Tanggal Berangkat" : "Tanggal Kembali";
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