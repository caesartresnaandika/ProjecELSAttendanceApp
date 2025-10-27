// lib/screens/Ijin/IjinScreen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:project_aplikasi_absensi_hrd_els/services/api_services.dart';
import 'package:project_aplikasi_absensi_hrd_els/services/session_manager.dart';

class IjinScreen extends StatefulWidget {
  const IjinScreen({super.key});

  @override
  State<IjinScreen> createState() => _IjinScreenState();
}

class _IjinScreenState extends State<IjinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  // State
  final _reasonController = TextEditingController();
  String? _selectedSubType = 'Ijin Telat';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _pickedFile;
  bool _isLoading = false;

  final List<String> _ijinSubTypes = ['Ijin Telat', 'Ijin Pulang Cepat', 'Ijin Tidak Masuk', 'Ijin Lainnya'];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
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

  Future<void> _submitIjin() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _pickedFile == null) {
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

      String formattedTime = _selectedTime != null ? _selectedTime!.format(context) : "seharian";
      String description = "Waktu: $formattedTime. Alasan: ${_reasonController.text}";

      final success = await _apiService.submitLeave(
        token: token,
        userId: userId,
        type: 'ijin',
        subType: _selectedSubType!,
        description: description,
        startDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        endDate: DateFormat('yyyy-MM-dd').format(_selectedDate!), // Untuk ijin, tanggal mulai & selesai sama
        startTime: _selectedTime != null ? "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00" : "00:00:00",
        endTime: "23:59:59",
        photoPath: _pickedFile!.path,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengajuan ijin berhasil dikirim!'), backgroundColor: Colors.green));
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
        title: const Text('Pengajuan Ijin', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
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

  // --- WIDGET BUILDERS ---

  Widget _buildHistoryButton() {
    return InkWell(
      onTap: () {
        // TODO: Arahkan ke halaman riwayat ijin jika sudah dibuat
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Halaman riwayat belum tersedia')));
      },
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
                  Text("Lihat Riwayat Ijin", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            const Text("Ajukan Ijin", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 24),

            const Text("Jenis Ijin", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedSubType,
              items: _ijinSubTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (value) => setState(() => _selectedSubType = value),
              decoration: _inputDecoration(),
            ),
            const SizedBox(height: 16),

            // --- Tanggal dan Waktu ---
            Row(
              children: [
                Expanded(child: _buildDatePickerField()),
                const SizedBox(width: 16),
                Expanded(child: _buildTimePickerField()),
              ],
            ),
            const SizedBox(height: 16),

            const Text("Alasan Ijin", style: TextStyle(color: Colors.grey)),
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

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitIjin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Text("AJUKAN IJIN", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Tanggal", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_selectedDate == null ? 'Pilih tanggal' : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
                const Icon(Icons.calendar_today, color: Colors.orange, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Waktu", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectTime(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_selectedTime == null ? 'Pilih waktu' : _selectedTime!.format(context)),
                const Icon(Icons.access_time, color: Colors.orange, size: 20),
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
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
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