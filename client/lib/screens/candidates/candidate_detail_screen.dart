import 'package:flutter/material.dart';
import 'package:recruitment_frontend/widgets/glassmorphic_container.dart';
import 'package:recruitment_frontend/utils/constants.dart';
import 'package:recruitment_frontend/models/candidate_model.dart';

class CandidateDetailScreen extends StatelessWidget {
  const CandidateDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Candidate candidate =
        ModalRoute.of(context)!.settings.arguments as Candidate;

    return Scaffold(
      appBar: AppBar(
        title: Text('Candidate Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: AppColors.primaryRed),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            GlassmorphicContainer(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryRed.withOpacity(0.2),
                    child: Text(
                      '${candidate.firstName[0]}${candidate.lastName[0]}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidate.fullName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          candidate.currentTitle,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.lightText,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          candidate.currentCompany,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Contact Information
            GlassmorphicContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildContactItem(Icons.email, candidate.email),
                  _buildContactItem(Icons.phone, candidate.phone),
                  _buildContactItem(Icons.location_on, candidate.location),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Skills Section
            GlassmorphicContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skills',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: candidate.skills
                        .map(
                          (skill) => Chip(
                            label: Text(
                              '${skill.skill} (${skill.yearsExperience} yrs)',
                            ),
                            backgroundColor: AppColors.primaryRed.withOpacity(
                              0.1,
                            ),
                            labelStyle: TextStyle(color: AppColors.primaryRed),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Experience Summary
            ...[
              GlassmorphicContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      candidate.summary,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.lightText,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('Schedule Interview'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryRed,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppColors.primaryRed),
                    ),
                    child: Text('Send Message'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryRed, size: 20),
          SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(fontSize: 14, color: AppColors.lightText),
          ),
        ],
      ),
    );
  }
}
