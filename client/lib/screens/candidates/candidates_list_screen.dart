import 'package:flutter/material.dart';
import 'package:recruitment_frontend/widgets/glassmorphic_container.dart';
import 'package:recruitment_frontend/utils/constants.dart';
import 'package:recruitment_frontend/models/candidate_model.dart';

class CandidatesListScreen extends StatefulWidget {
  const CandidatesListScreen({super.key});

  @override
  _CandidatesListScreenState createState() => _CandidatesListScreenState();
}

class _CandidatesListScreenState extends State<CandidatesListScreen> {
  final List<Candidate> _candidates = [
  Candidate(
    id: 1,
    firstName: 'John',
    lastName: 'Doe',
    email: 'john.doe@email.com',
    phone: '+1 (555) 123-4567',
    location: 'San Francisco, CA',
    currentCompany: 'TechCorp',
    currentTitle: 'Senior Developer',
    totalExperience: 5.5,
    summary: 'Senior developer with experience in web and backend development.',
    cvPath: '/path/to/cv_john.pdf',
    consentGiven: true,
    consentDate: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(), // <-- add this
    skills: [
      CandidateSkill(
        id: 1,
        candidateId: 1,
        skill: 'Python',
        yearsExperience: 5,
        proficiencyLevel: 'Expert',
      ),
      CandidateSkill(
        id: 2,
        candidateId: 1,
        skill: 'JavaScript',
        yearsExperience: 4,
        proficiencyLevel: 'Advanced',
      ),
    ],
  ),
  Candidate(
    id: 2,
    firstName: 'Jane',
    lastName: 'Smith',
    email: 'jane.smith@email.com',
    phone: '+1 (555) 987-6543',
    location: 'New York, NY',
    currentCompany: 'DataSystems',
    currentTitle: 'Data Scientist',
    totalExperience: 4.0,
    summary: 'Data scientist specializing in predictive modeling and analytics.',
    cvPath: '/path/to/cv_jane.pdf',
    consentGiven: true,
    consentDate: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(), // <-- add this
    skills: [
      CandidateSkill(
        id: 3,
        candidateId: 2,
        skill: 'Python',
        yearsExperience: 4,
        proficiencyLevel: 'Advanced',
      ),
      CandidateSkill(
        id: 4,
        candidateId: 2,
        skill: 'R',
        yearsExperience: 3,
        proficiencyLevel: 'Intermediate',
      ),
    ],
  ),
];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-candidate');
        },
        backgroundColor: AppColors.primaryRed,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Candidates',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                IconButton(
                  icon: Icon(Icons.search, color: AppColors.primaryRed),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Search and Filter
            GlassmorphicContainer(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search candidates...',
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.filter_list, color: AppColors.primaryRed),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Candidates List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _candidates.length,
              itemBuilder: (context, index) {
                final candidate = _candidates[index];
                return _buildCandidateCard(candidate);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateCard(Candidate candidate) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/candidate-detail',
          arguments:
              candidate, // Safe to pass because Candidate has all required fields
        );
      },
      child: GlassmorphicContainer(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: AppColors.primaryRed.withOpacity(0.2),
              child: Text(
                '${candidate.firstName[0]}${candidate.lastName[0]}',
                style: TextStyle(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Candidate Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    candidate.fullName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    candidate.currentTitle,
                    style: TextStyle(fontSize: 14, color: AppColors.lightText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    candidate.currentCompany,
                    style: TextStyle(fontSize: 12, color: AppColors.mediumGray),
                  ),
                ],
              ),
            ),
            // Skills Preview
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Wrap(
                  spacing: 4,
                  children: candidate.skills
                      .take(2)
                      .map(
                        (skill) => Chip(
                          label: Text(skill.skill),
                          backgroundColor: AppColors.primaryRed.withOpacity(
                            0.1,
                          ),
                          labelStyle: TextStyle(
                            fontSize: 10,
                            color: AppColors.primaryRed,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 4),
                Text(
                  '${candidate.totalExperience} yrs exp',
                  style: TextStyle(fontSize: 12, color: AppColors.mediumGray),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
