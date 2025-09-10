class Candidate {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String location;
  final String currentCompany;
  final String currentTitle;
  final double totalExperience;
  final String summary;
  final String cvPath;
  final bool consentGiven;
  final DateTime consentDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CandidateSkill> skills;

  Candidate({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.location,
    required this.currentCompany,
    required this.currentTitle,
    required this.totalExperience,
    required this.summary,
    required this.cvPath,
    required this.consentGiven,
    required this.consentDate,
    required this.createdAt,
    required this.updatedAt,
    this.skills = const [],
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      location: json['location'],
      currentCompany: json['current_company'],
      currentTitle: json['current_title'],
      totalExperience: json['total_experience']?.toDouble(),
      summary: json['summary'],
      cvPath: json['cv_path'],
      consentGiven: json['consent_given'],
      consentDate: json['consent_date'] != null
          ? DateTime.parse(json['consent_date'])
          : DateTime.now(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      skills: (json['skills'] as List? ?? [])
          .map((skill) => CandidateSkill.fromJson(skill))
          .toList(),
    );
  }

  String get fullName => '$firstName $lastName';
}

class CandidateSkill {
  final int id;
  final int candidateId;
  final String skill;
  final double yearsExperience;
  final String proficiencyLevel;

  CandidateSkill({
    required this.id,
    required this.candidateId,
    required this.skill,
    required this.yearsExperience,
    required this.proficiencyLevel,
  });

  factory CandidateSkill.fromJson(Map<String, dynamic> json) {
    return CandidateSkill(
      id: json['id'],
      candidateId: json['candidate_id'],
      skill: json['skill'],
      yearsExperience: json['years_experience']?.toDouble(),
      proficiencyLevel: json['proficiency_level'],
    );
  }
}
