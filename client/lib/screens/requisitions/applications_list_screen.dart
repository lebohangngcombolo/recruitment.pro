import 'package:flutter/material.dart';
import 'package:recruitment_frontend/widgets/glassmorphic_container.dart';
import 'package:recruitment_frontend/utils/constants.dart';
import 'package:recruitment_frontend/models/requisition_model.dart';
import 'package:recruitment_frontend/models/candidate_model.dart';

class ApplicationsListScreen extends StatelessWidget {
  final Requisition requisition;

  ApplicationsListScreen({super.key, required this.requisition});

  final List<Application> _applications = [
    Application(
      id: 1,
      candidateId: 101,
      requisitionId: 1,
      cvMatchScore: 85,
      assessmentScore: 78,
      overallScore: 82,
      status: 'recommended',
      recommendation: 'proceed',
    ),
    Application(
      id: 2,
      candidateId: 102,
      requisitionId: 1,
      cvMatchScore: 92,
      assessmentScore: 65,
      overallScore: 82,
      status: 'hold',
      recommendation: 'hold',
    ),
    Application(
      id: 3,
      candidateId: 103,
      requisitionId: 1,
      cvMatchScore: 45,
      assessmentScore: 50,
      overallScore: 47,
      status: 'rejected',
      recommendation: 'reject',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Applications for ${requisition.title}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    _applications.length.toString(),
                    Icons.people,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Recommended',
                    _applications
                        .where((a) => a.recommendation == 'proceed')
                        .length
                        .toString(),
                    Icons.thumb_up,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'On Hold',
                    _applications
                        .where((a) => a.recommendation == 'hold')
                        .length
                        .toString(),
                    Icons.pause,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Rejected',
                    _applications
                        .where((a) => a.recommendation == 'reject')
                        .length
                        .toString(),
                    Icons.thumb_down,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  SizedBox(width: 8),
                  _buildFilterChip('Recommended', 'proceed'),
                  SizedBox(width: 8),
                  _buildFilterChip('On Hold', 'hold'),
                  SizedBox(width: 8),
                  _buildFilterChip('Rejected', 'reject'),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Applications List
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _applications.length,
              itemBuilder: (context, index) {
                final application = _applications[index];
                return _buildApplicationCard(application);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return GlassmorphicContainer(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, size: 24, color: AppColors.primaryRed),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: AppColors.lightText),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: false,
      onSelected: (selected) {
        // Filter logic
      },
      selectedColor: AppColors.primaryRed,
      labelStyle: TextStyle(color: Colors.white),
    );
  }

  Widget _buildApplicationCard(Application application) {
    final candidate = _getCandidate(application.candidateId);
    final statusColor = _getStatusColor(application.status);

    return GlassmorphicContainer(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                candidate.fullName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  application.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            candidate.currentTitle,
            style: TextStyle(fontSize: 14, color: AppColors.lightText),
          ),
          SizedBox(height: 16),
          // Scores
          Row(
            children: [
              _buildScoreItem('CV Match', '${application.cvMatchScore}%'),
              SizedBox(width: 16),
              _buildScoreItem('Assessment', '${application.assessmentScore}%'),
              SizedBox(width: 16),
              _buildScoreItem('Overall', '${application.overallScore}%'),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // View candidate details
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryRed,
                    side: BorderSide(color: AppColors.primaryRed),
                  ),
                  child: Text('View Profile'),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Schedule interview
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                  ),
                  child: Text('Schedule Interview'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryRed,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: AppColors.mediumGray),
        ),
      ],
    );
  }

  Candidate _getCandidate(int candidateId) {
  // Mock candidate data - in real app, this would come from API
  final now = DateTime.now();
  return Candidate(
    consentGiven: true,
    consentDate: now,      // ✅ add this
    createdAt: now,        // ✅ add this
    updatedAt: now,        // ✅ add this
    id: candidateId,
    phone: '1234567890',
    location: 'Nairobi',
    totalExperience: 5,
    summary: 'Experienced software developer',
    cvPath: 'assets/cv.pdf',
    firstName: 'Candidate',
    lastName: '$candidateId',
    email: 'candidate$candidateId@email.com',
    currentTitle: 'Software Developer',
    currentCompany: 'Tech Company',
  );
}


  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'recommended':
        return Colors.green;
      case 'hold':
        return Colors.orange;
      case 'rejected':
        return AppColors.primaryRed;
      default:
        return AppColors.mediumGray;
    }
  }
}

class Application {
  final int id;
  final int candidateId;
  final int requisitionId;
  final double cvMatchScore;
  final double assessmentScore;
  final double overallScore;
  final String status;
  final String recommendation;

  Application({
    required this.id,
    required this.candidateId,
    required this.requisitionId,
    required this.cvMatchScore,
    required this.assessmentScore,
    required this.overallScore,
    required this.status,
    required this.recommendation,
  });
}
