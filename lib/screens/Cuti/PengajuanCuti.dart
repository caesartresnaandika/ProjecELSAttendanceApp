import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PengajuanCuti extends StatefulWidget {
  const PengajuanCuti({Key? key}) : super(key: key);

  @override
  _PengajuanCutiState createState() => _PengajuanCutiState();
}

class _PengajuanCutiState extends State<PengajuanCuti> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  String _leaveType = 'Tahunan';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  // Dummy data untuk riwayat cuti
  final List<Map<String, dynamic>> _leaveHistory = [
    {'type': 'Tahunan', 'dates': '15-18 Nov 2024', 'status': 'Disetujui', 'color': Colors.green},
    {'type': 'Sakit', 'dates': '5 Nov 2024', 'status': 'Disetujui', 'color': Colors.green},
    {'type': 'Penting', 'dates': '25 Okt 2024', 'status': 'Ditolak', 'color': Colors.red},
    {'type': 'Tahunan', 'dates': '10-12 Sep 2024', 'status': 'Disetujui', 'color': Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengajuan Cuti'),
        backgroundColor: Colors.orange[700],
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Pengajuan
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'Ajukan Cuti Baru',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _leaveType,
                        decoration: InputDecoration(
                          labelText: 'Jenis Cuti',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: ['Tahunan', 'Sakit', 'Melahirkan', 'Penting']
                            .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _leaveType = value!;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _startDateController,
                        decoration: InputDecoration(
                          labelText: 'Tanggal Mulai',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: Icon(Icons.calendar_today, color: Colors.orange[700]),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context, isStartDate: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pilih tanggal mulai';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _endDateController,
                        decoration: InputDecoration(
                          labelText: 'Tanggal Selesai',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: Icon(Icons.calendar_today, color: Colors.orange[700]),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context, isStartDate: false),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pilih tanggal selesai';
                          }
                          if (_startDate != null && _endDate != null && _endDate!.isBefore(_startDate!)) {
                            return 'Tanggal selesai harus setelah tanggal mulai';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _reasonController,
                        decoration: InputDecoration(
                          labelText: 'Alasan Cuti',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan alasan cuti';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        onPressed: _submitLeaveRequest,
                        child: Text('Ajukan Cuti'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),

            // Riwayat Pengajuan
            Text(
              'Riwayat Pengajuan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            ..._leaveHistory.map((history) => Card(
              margin: EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.beach_access, color: Colors.orange[700]),
                ),
                title: Text(history['type']),
                subtitle: Text(history['dates']),
                trailing: Chip(
                  label: Text(
                    history['status'],
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: history['color'],
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
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
        if (isStartDate) {
          _startDate = picked;
          _startDateController.text = DateFormat('dd MMM yyyy').format(picked);
        } else {
          _endDate = picked;
          _endDateController.text = DateFormat('dd MMM yyyy').format(picked);
        }
      });
    }
  }

  void _submitLeaveRequest() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulasi proses loading
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pengajuan cuti berhasil dikirim!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        _formKey.currentState!.reset();
        _startDateController.clear();
        _endDateController.clear();
        _reasonController.clear();
        setState(() {
          _leaveType = 'Tahunan';
        });
      });
    }
  }
}