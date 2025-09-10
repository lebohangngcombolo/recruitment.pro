class AssessmentPack {
  final int id;
  final String name;
  final String description;
  final String type;
  final List<dynamic> questions;
  final int timeLimit;
  final double passingScore;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  AssessmentPack({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.questions,
    required this.timeLimit,
    required this.passingScore,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssessmentPack.fromJson(Map<String, dynamic> json) {
    return AssessmentPack(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      questions: json['questions'] ?? [],
      timeLimit: json['time_limit'],
      passingScore: json['passing_score']?.toDouble(),
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class AssessmentResult {
  final int id;
  final int applicationId;
  final double score;
  final List<dynamic> answers;
  final int timeTaken;
  final DateTime completedAt;
  final String evaluatorNotes;

  AssessmentResult({
    required this.id,
    required this.applicationId,
    required this.score,
    required this.answers,
    required this.timeTaken,
    required this.completedAt,
    required this.evaluatorNotes,
  });

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    return AssessmentResult(
      id: json['id'],
      applicationId: json['application_id'],
      score: json['score']?.toDouble(),
      answers: json['answers'] ?? [],
      timeTaken: json['time_taken'],
      completedAt: DateTime.parse(json['completed_at']),
      evaluatorNotes: json['evaluator_notes'],
    );
  }
}
