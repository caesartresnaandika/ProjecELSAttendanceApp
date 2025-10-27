class LeaveData {
  final String id;
  final String employeeId;
  final String inputDatetime;
  final String image;
  final String type;
  final String subType;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String description;

  LeaveData({
    required this.id,
    required this.employeeId,
    required this.inputDatetime,
    required this.image,
    required this.type,
    required this.subType,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.description,
  });

  factory LeaveData.fromJson(Map<String, dynamic> json) {
    return LeaveData(
      id: json['id'] ?? '',
      employeeId: json['employee_id'] ?? '',
      inputDatetime: json['input_datetime'] ?? '',
      image: json['image'],
      type: json['type'] ?? '',
      subType: json['sub_type'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      description: json['description'] ?? '',
    );
  }
}