import '../enums/attendance_status.dart';

class EventAttendance {
  String id;
  String eventId;
  String userId;
  AttendanceStatus status;

  EventAttendance({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
  });

  EventAttendance.fromJson(Map<String, dynamic> data, String id)
      : id = id,
        eventId = data['eventId'],
        userId = data['userId'],
        status = AttendanceStatus.values.firstWhere(
              (e) => e.name == data['status'],
        );

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'userId': userId,
      'status': status.name,
    };
  }
}