import 'package:flutter/foundation.dart';

class ScanLogs {
  final String logsId;
  final String eventId;
  final String employeeId;
  final String logsDate;
  final String logsTime;
  final String timestamp;
  final String remarks;
  final String user_id;
  final String status_remarks;

  ScanLogs({
    required this.logsId,
    required this.eventId,
    required this.employeeId,
    required this.logsDate,
    required this.logsTime,
    required this.timestamp,
    required this.remarks,
    required this.user_id,
    required this.status_remarks,
  });

  factory ScanLogs.fromJson(Map<String, dynamic> json) {
    return ScanLogs(
      logsId: json['logs_id'],
      eventId: json['event_id'],
      employeeId: json['employee_id'],
      logsDate: json['logs_date'],
      logsTime: json['logs_time'],
      timestamp: json['timestamp'],
      remarks: json['remarks'],
      user_id: json['user_id'],
      status_remarks: json['status_remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logs_id': logsId,
      'event_id': eventId,
      'employee_id': employeeId,
      'logs_date': logsDate,
      'logs_time': logsTime,
      'timestamp': timestamp,
      'remarks': remarks,
      'user_id': user_id,
      'status_remarks': status_remarks,
    };
  }
}
