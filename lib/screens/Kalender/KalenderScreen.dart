import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KalenderScreen extends StatefulWidget {
  const KalenderScreen({Key? key}) : super(key: key);

  @override
  _KalenderScreenState createState() => _KalenderScreenState();
}

class _KalenderScreenState extends State<KalenderScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<DateTime> _publicHolidays = [
    DateTime(DateTime.now().year, 1, 1),   // Tahun Baru
    DateTime(DateTime.now().year, 12, 25), // Natal
    DateTime(DateTime.now().year, 8, 17),  // Kemerdekaan
  ];

  final List<Map<String, dynamic>> _events = [
    {'date': DateTime(2025, 9, 20), 'title': 'Ijin Dokter', 'type': 'ijin', 'completed': false},
    {'date': DateTime(2025, 9, 20), 'title': 'Ijin', 'type': 'ijin', 'completed': true},
    {'date': DateTime(2025, 9, 15), 'title': 'Cuti Tahunan', 'type': 'cuti', 'completed': false},
    {'date': DateTime(2025, 9, 25), 'title': 'Meeting Client', 'type': 'meeting', 'completed': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kalender Kerja'),
        backgroundColor: Colors.orange[700],
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header dengan bulan dan tahun
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.orange[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, color: Colors.orange[700]),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_selectedDate),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: Colors.orange[700]),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
          ),

          // Grid hari dalam seminggu
          Container(
            color: Colors.orange[100],
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
              ),
              itemCount: 7,
              itemBuilder: (context, index) {
                final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                return Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    days[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: index >= 5 ? Colors.red : Colors.orange[700],
                    ),
                  ),
                );
              },
            ),
          ),

          // Grid kalender
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
              ),
              itemCount: _getDaysInMonth() + _getFirstWeekday(),
              itemBuilder: (context, index) {
                if (index < _getFirstWeekday()) {
                  return Container(); // Hari kosong di awal bulan
                }

                final day = index - _getFirstWeekday() + 1;
                final currentDate = DateTime(_selectedDate.year, _selectedDate.month, day);
                final isToday = _isSameDay(currentDate, DateTime.now());
                final isHoliday = _publicHolidays.any((date) => _isSameDay(date, currentDate));
                final isWeekend = currentDate.weekday == 6 || currentDate.weekday == 7;
                final hasEvent = _events.any((event) => _isSameDay(event['date'], currentDate));

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = currentDate;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isToday ? Colors.orange[700]! :
                      isHoliday ? Colors.red[50]! :
                      isWeekend ? Colors.grey[50]! :
                      Colors.white,
                      border: Border.all(
                        color: _isSameDay(currentDate, _selectedDate) ? Colors.orange : Colors.grey[200]!,
                        width: _isSameDay(currentDate, _selectedDate) ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            day.toString(),
                            style: TextStyle(
                              color: isToday ? Colors.white :
                              isHoliday ? Colors.red :
                              isWeekend ? Colors.red :
                              Colors.black,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (hasEvent)
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.orange[700]!,
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

          // Event list untuk tanggal yang dipilih
          Container(
            height: 200,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Event pada ${DateFormat('dd MMM yyyy').format(_selectedDate)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 12),
                Expanded(
                  child: _getEventsForSelectedDate().isEmpty
                      ? Center(child: Text('Tidak ada event', style: TextStyle(color: Colors.grey)))
                      : ListView(
                    children: _getEventsForSelectedDate().map((event) => ListTile(
                      leading: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: event['completed'] ? Colors.green : Colors.transparent,
                          border: Border.all(
                            color: event['completed'] ? Colors.green : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: event['completed']
                            ? Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                      title: Text(event['title']),
                      subtitle: Text(_getEventTypeText(event['type'])),
                      trailing: Icon(
                        _getEventIcon(event['type']),
                        color: Colors.orange[700],
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  String _getEventTypeText(String type) {
    switch (type) {
      case 'cuti': return 'Cuti';
      case 'ijin': return 'Ijin';
      case 'meeting': return 'Meeting';
      default: return 'Event';
    }
  }
}