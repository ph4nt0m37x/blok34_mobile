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
}