class Interview {
  final int id;
  final int applicationId;
  final String type;
  final DateTime scheduledDate;
  final int duration;
  final List<int> interviewers;
  final String status;
  final List<dynamic> feedback;
  final double rating;

  Interview({
    required this.id,
    required this.applicationId,
    required this.type,
    required this.scheduledDate,
    required this.duration,
    required this.interviewers,
    required this.status,
    this.feedback = const [],  // optional default
    this.rating = 0.0,         // optional default
  });

  factory Interview.fromJson(Map<String, dynamic> json) {
    return Interview(
      id: json['id'],
      applicationId: json['application_id'],
      type: json['type'],
      scheduledDate: DateTime.parse(json['scheduled_date']),
      duration: json['duration'],
      interviewers: List<int>.from(json['interviewers'] ?? []),
      status: json['status'],
      feedback: json['feedback'] ?? [],
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }
}
