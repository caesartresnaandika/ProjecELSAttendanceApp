import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KalenderScreen extends StatefulWidget {
  const KalenderScreen({Key? key}) : super(key: key);

  @override
  _KalenderScreenState createState() => _KalenderScreenState();
}

class _KalenderScreenState extends State<KalenderScreen> with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  final List<DateTime> _publicHolidays = [
    DateTime(DateTime.now().year, 1, 1),   // Tahun Baru
    DateTime(DateTime.now().year, 12, 25), // Natal
    DateTime(DateTime.now().year, 8, 17),  // Kemerdekaan
  ];

  final List<Map<String, dynamic>> _events = [
    {'date': DateTime(2025, 9, 20), 'title': 'Ijin Dokter', 'type': 'ijin', 'completed': false},
    {'date': DateTime(2025, 9, 20), 'title': 'Rapat Internal', 'type': 'ijin', 'completed': true},
    {'date': DateTime(2025, 9, 15), 'title': 'Cuti Tahunan', 'type': 'cuti', 'completed': false},
    {'date': DateTime(2025, 9, 25), 'title': 'Meeting Client', 'type': 'meeting', 'completed': false},
  ];

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Kalender Kerja',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // 👉 HEADER BULAN
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.grey),
                  onPressed: () => _changeMonth(-1),
                ),
                GestureDetector(
                  onTap: _showMonthYearPicker, // 👈 Tambahkan onTap
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Text(
                          DateFormat('MMMM yyyy').format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF6F00),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.grey),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
          ),

          // 👉 HEADER HARI (Sen - Min)
          Container(
            color: Colors.white,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: 7,
              itemBuilder: (context, index) {
                final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                final isWeekend = index >= 6;
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isWeekend ? Colors.red.withOpacity(0.3) : Colors.orange.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    days[index],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isWeekend ? Colors.red : const Color(0xFFFF6F00),
                    ),
                  ),
                );
              },
            ),
          ),

          // 👉 GRID KALENDER
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: _getDaysInMonth() + _getFirstWeekday(),
              itemBuilder: (context, index) {
                if (index < _getFirstWeekday()) {
                  return const SizedBox(); // Spacer
                }

                final day = index - _getFirstWeekday() + 1;
                final currentDate = DateTime(_selectedDate.year, _selectedDate.month, day);
                final isToday = _isSameDay(currentDate, DateTime.now());
                final isHoliday = _publicHolidays.any((date) => _isSameDay(date, currentDate));
                final isWeekend = currentDate.weekday == 7;
                final hasEvent = _events.any((event) => _isSameDay(event['date'], currentDate));

                // ✅ PINDAHKAN LOGIKA Warna ke luar decoration
                final backgroundColor = _getDayBackgroundColor(currentDate, isToday, isHoliday, isWeekend);
                final textColor = _getDayTextColor(isToday, isHoliday, isWeekend);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = currentDate;
                    });
                    _animationController.forward();
                    Future.delayed(const Duration(milliseconds: 300), () {
                      _animationController.reverse();
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isSameDay(currentDate, _selectedDate)
                            ? const Color(0xFFFF6F00)
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: _isSameDay(currentDate, _selectedDate)
                          ? [
                        BoxShadow(
                          color: const Color(0xFFFF6F00).withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          day.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: textColor,
                          ),
                        ),
                        if (hasEvent)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF6F00),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 👉 EVENT LIST
          Container(
            height: 220,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(13, 0, 0, 0),
                  blurRadius: 10,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Event pada ${DateFormat('EEEE, d MMMM y', 'id_ID').format(_selectedDate)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _getEventsForSelectedDate().isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_available, color: Colors.grey, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          "Tidak ada agenda",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                      : ListView(
                    children: _getEventsForSelectedDate().map((event) {
                      final icon = _getEventIcon(event['type']);
                      final color = _getEventTypeColor(event['type']);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                            border: Border(left: BorderSide(width: 4, color: color))
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(icon, color: color, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event['title'],
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        event['completed']
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        size: 14,
                                        color: event['completed']
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        event['completed'] ? "Selesai" : "Belum selesai",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: event['completed']
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Fungsi untuk mendapatkan warna background
  Color _getDayBackgroundColor(DateTime date, bool isToday, bool isHoliday, bool isWeekend) {
    if (isToday) return const Color(0xFFFF6F00);
    if (isHoliday) return Colors.red.withOpacity(0.1);
    if (isWeekend) return Colors.grey.withOpacity(0.1);
    return Colors.white;
  }

  // ✅ Fungsi untuk mendapatkan warna teks
  Color _getDayTextColor(bool isToday, bool isHoliday, bool isWeekend) {
    if (isToday) return Colors.white;
    if (isHoliday || isWeekend) return Colors.red;
    return Colors.black87;
  }

  int _getDaysInMonth() {
    return DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
  }

  int _getFirstWeekday() {
    return DateTime(_selectedDate.year, _selectedDate.month, 1).weekday - 1;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + delta, 1);
    });

  }
  void _showMonthYearPicker() {
    // Inisialisasi nilai awal
    int selectedMonth = _selectedDate.month;
    int selectedYear = _selectedDate.year;

    // Daftar bulan
    final List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    // Rentang tahun (misal: 5 tahun ke belakang & 5 tahun ke depan)
    final List<int> years = List.generate(11, (index) => DateTime.now().year - 5 + index);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Pilih Bulan & Tahun"),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dropdown Bulan
                DropdownButtonFormField<int>(
                  value: selectedMonth,
                  decoration: const InputDecoration(labelText: "Bulan"),
                  items: List.generate(12, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text(months[index]),
                    );
                  }),
                  onChanged: (value) {
                    selectedMonth = value!;
                  },
                ),
                const SizedBox(height: 16),
                // Dropdown Tahun
                DropdownButtonFormField<int>(
                  value: selectedYear,
                  decoration: const InputDecoration(labelText: "Tahun"),
                  items: years.map((year) {
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedYear = value!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedDate = DateTime(selectedYear, selectedMonth, 1);
                });
                Navigator.pop(context);
                // Trigger animasi
                _animationController.forward();
                Future.delayed(const Duration(milliseconds: 300), () {
                  _animationController.reverse();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6F00),
              ),
              child: const Text("Pilih", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
  List<Map<String, dynamic>> _getEventsForSelectedDate() {
    return _events.where((event) => _isSameDay(event['date'], _selectedDate)).toList();
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'cuti': return Icons.beach_access;
      case 'ijin': return Icons.person_outline;
      case 'meeting': return Icons.meeting_room;
      default: return Icons.event;
    }
  }

  Color _getEventTypeColor(String type) {
    switch (type) {
      case 'cuti': return Colors.blue;
      case 'ijin': return const Color(0xFFFF6F00); // Orange brand
      case 'meeting': return Colors.purple;
      default: return Colors.grey;
    }
  }
}