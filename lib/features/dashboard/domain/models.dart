class Schedule {
  final int id;
  final String siteName;
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  Schedule({
    required this.id,
    required this.siteName,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] ?? 0,
      siteName: json['site_name'] ?? '',
      startTime: DateTime.parse(json['start_time'] ?? ''),
      endTime: DateTime.parse(json['end_time'] ?? ''),
      status: json['status'] ?? 'not_started',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'site_name': siteName,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status,
    };
  }
}

class CheckInRequest {
  final int shiftId;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String imagePath;

  CheckInRequest({
    required this.shiftId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'shift_id': shiftId,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Map<String, String> toFormData() {
    return {
      'shift_id': shiftId.toString(),
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    };
  }
}

class CheckOutRequest {
  final int shiftId;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String imagePath;

  CheckOutRequest({
    required this.shiftId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'shift_id': shiftId,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Map<String, String> toFormData() {
    return {
      'shift_id': shiftId.toString(),
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    };
  }
}
