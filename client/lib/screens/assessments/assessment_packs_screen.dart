import 'package:flutter/material.dart';
import 'package:recruitment_frontend/widgets/glassmorphic_container.dart';
import 'package:recruitment_frontend/utils/constants.dart';

class AssessmentPacksScreen extends StatelessWidget {
  final List<AssessmentPack> _assessmentPacks = [
    AssessmentPack(
      id: 1,
      name: 'Technical Skills - Python',
      description: 'Assess Python programming skills',
      type: 'technical',
      timeLimit: 45,
      passingScore: 70,
    ),
    AssessmentPack(
      id: 2,
      name: 'Behavioral Questions',
      description: 'Evaluate soft skills and cultural fit',
      type: 'behavioral',
      timeLimit: 30,
      passingScore: 60,
    ),
    AssessmentPack(
      id: 3,
      name: 'Cognitive Ability',
      description: 'Test problem-solving and critical thinking',
      type: 'cognitive',
      timeLimit: 60,
      passingScore: 65,
    ),
  ];

 AssessmentPacksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryRed,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assessment Packs',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 20),
            // Search and Filter
            GlassmorphicContainer(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search assessment packs...',
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
            // Assessment Packs Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _assessmentPacks.length,
              itemBuilder: (context, index) {
                final pack = _assessmentPacks[index];
                return _buildAssessmentPackCard(pack);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentPackCard(AssessmentPack pack) {
    Color getTypeColor(String type) {
      switch (type) {
        case 'technical':
          return Colors.blue;
        case 'behavioral':
          return Colors.green;
        case 'cognitive':
          return Colors.orange;
        default:
          return AppColors.primaryRed;
      }
    }

    return GlassmorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: getTypeColor(pack.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              pack.type.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: getTypeColor(pack.type),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Pack Name
          Text(
            pack.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Description
          Text(
            pack.description,
            style: TextStyle(fontSize: 12, color: AppColors.lightText),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          // Metrics
          Row(
            children: [
              _buildMetricItem(Icons.access_time, '${pack.timeLimit} min'),
              const SizedBox(width: 12),
              _buildMetricItem(Icons.score, '${pack.passingScore}% pass'),
            ],
          ),
          const SizedBox(height: 16),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryRed, // ✅ updated
                    side: BorderSide(color: AppColors.primaryRed),
                  ),
                  child: const Text('Preview'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed, // ✅ updated
                    foregroundColor: Colors.white, // ✅ replaces onPrimary
                  ),
                  child: const Text('Use'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.mediumGray),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: AppColors.mediumGray)),
      ],
    );
  }
}

/// Dummy data model (replace with your real model later)
class AssessmentPack {
  final int id;
  final String name;
  final String description;
  final String type;
  final int timeLimit;
  final int passingScore;

  AssessmentPack({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.timeLimit,
    required this.passingScore,
  });
}
