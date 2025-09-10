class Requisition {
  final int id;
  final String title;
  final String department;
  final String description;
  final String requirements;
  final List<dynamic> requiredSkills;
  final int minExperience;
  final String location;
  final String seniorityLevel;
  final String status;
  final Map<String, dynamic> weightings;
  final List<dynamic> knockoutRules;
  final int assessmentPackId;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Requisition({
    required this.id,
    required this.title,
    required this.department,
    required this.description,
    required this.requirements,
    required this.requiredSkills,
    required this.minExperience,
    required this.location,
    required this.seniorityLevel,
    required this.status,
    required this.weightings,
    required this.knockoutRules,
    required this.assessmentPackId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Requisition.fromJson(Map<String, dynamic> json) {
    return Requisition(
      id: json['id'],
      title: json['title'],
      department: json['department'],
      description: json['description'],
      requirements: json['requirements'],
      requiredSkills: json['required_skills'] ?? [],
      minExperience: json['min_experience'] ?? 0,
      location: json['location'] ?? '',
      seniorityLevel: json['seniority_level'] ?? '',
      status: json['status'] ?? 'pending',
      weightings: Map<String, dynamic>.from(json['weightings'] ?? {}),
      knockoutRules: json['knockout_rules'] ?? [],
      assessmentPackId: json['assessment_pack_id'] ?? 0,
      createdBy: json['created_by'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
