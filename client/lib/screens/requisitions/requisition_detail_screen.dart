import 'package:flutter/material.dart';
import 'package:recruitment_frontend/widgets/glassmorphic_container.dart';
import 'package:recruitment_frontend/utils/constants.dart';
import 'package:recruitment_frontend/screens/requisitions/applications_list_screen.dart';
import 'package:recruitment_frontend/models/requisition_model.dart';

class RequisitionDetailScreen extends StatelessWidget {
  final Requisition requisition;

  const RequisitionDetailScreen({super.key, required this.requisition});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Requisition Details'),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        requisition.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            requisition.status,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          requisition.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(requisition.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    requisition.department,
                    style: TextStyle(fontSize: 16, color: AppColors.lightText),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      _buildDetailItem(Icons.location_on, requisition.location),
                      SizedBox(width: 16),
                      _buildDetailItem(Icons.work, requisition.seniorityLevel),
                      SizedBox(width: 16),
                      _buildDetailItem(
                        Icons.access_time,
                        '${requisition.minExperience}+ yrs',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Description Section
            GlassmorphicContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Job Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    requisition.description,
                    style: TextStyle(fontSize: 14, color: AppColors.lightText),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Requirements Section
            GlassmorphicContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Requirements',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    requisition.requirements,
                    style: TextStyle(fontSize: 14, color: AppColors.lightText),
                  ),
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
                    'Required Skills',
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
                    children: requisition.requiredSkills.map((skill) {
                      return Chip(
                        label: Text(skill['name']),
                        backgroundColor: AppColors.primaryRed.withOpacity(0.1),
                        labelStyle: TextStyle(color: AppColors.primaryRed),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Scoring Weightings
            GlassmorphicContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scoring Weightings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildWeightingItem(
                    'CV Match',
                    '${requisition.weightings['cv']}%',
                  ),
                  _buildWeightingItem(
                    'Assessment',
                    '${requisition.weightings['assessment']}%',
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/applications',
                        arguments: requisition,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('View Applications'),
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
                    child: Text('Edit Requisition'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.mediumGray),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: AppColors.mediumGray)),
      ],
    );
  }

  Widget _buildWeightingItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: AppColors.lightText),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.green;
      case 'closed':
        return AppColors.primaryRed;
      case 'draft':
        return Colors.orange;
      case 'filled':
        return Colors.blue;
      default:
        return AppColors.mediumGray;
    }
  }
}
