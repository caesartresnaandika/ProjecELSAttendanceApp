import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  // Dummy data untuk riwayat ijin
  final List<Map<String, dynamic>> _permissionHistory = [
    {'type': 'Ijin Telat', 'date': '15 Nov 2024', 'time': '08:30', 'status': 'Disetujui', 'color': Colors.green},
    {'type': 'Pulang Cepat', 'date': '10 Nov 2024', 'time': '15:00', 'status': 'Disetujui', 'color': Colors.green},
    {'type': 'Tidak Masuk', 'date': '5 Nov 2024', 'time': '-', 'status': 'Ditolak', 'color': Colors.red},
    {'type': 'Ijin Lainnya', 'date': '28 Okt 2024', 'time': '10:00', 'status': 'Disetujui', 'color': Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengajuan Ijin'),
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
                        'Ajukan Ijin',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _permissionType,
                        decoration: InputDecoration(
                          labelText: 'Jenis Ijin',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
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
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: 'Tanggal',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: Icon(Icons.calendar_today, color: Colors.orange[700]),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pilih tanggal';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _timeController,
                        decoration: InputDecoration(
                          labelText: 'Waktu (jika diperlukan)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: Icon(Icons.access_time, color: Colors.orange[700]),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        readOnly: true,
                        onTap: () => _selectTime(context),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _reasonController,
                        decoration: InputDecoration(
                          labelText: 'Alasan Ijin',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan alasan ijin';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        onPressed: _submitPermissionRequest,
                        child: Text('Ajukan Ijin'),
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
            ..._permissionHistory.map((history) => Card(
              margin: EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_outline, color: Colors.orange[700]),
                ),
                title: Text(history['type']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(history['date']),
                    if (history['time'] != '-') Text('Jam: ${history['time']}'),
                  ],
                ),
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

  Future<void> _selectDate(BuildContext context) async {
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
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
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