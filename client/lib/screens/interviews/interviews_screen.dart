import 'package:flutter/material.dart';
import 'package:recruitment_frontend/widgets/glassmorphic_container.dart';
import 'package:recruitment_frontend/utils/constants.dart';
import 'package:recruitment_frontend/screens/interviews/schedule_interview_screen.dart';
import 'package:recruitment_frontend/screens/interviews/interview_feedback_screen.dart';
import 'package:recruitment_frontend/models/interview_model.dart';
import 'package:intl/intl.dart';

class InterviewsScreen extends StatefulWidget {
  const InterviewsScreen({super.key});

  @override
  _InterviewsScreenState createState() => _InterviewsScreenState();
}

class _InterviewsScreenState extends State<InterviewsScreen> {
  final List<Interview> _interviews = [
    Interview(
      id: 1,
      applicationId: 101,
      type: 'Video',
      scheduledDate: DateTime.now().add(Duration(days: 1)),
      duration: 60,
      interviewers: [1, 2],
      status: 'scheduled',
    ),
    Interview(
      id: 2,
      applicationId: 102,
      type: 'Onsite',
      scheduledDate: DateTime.now().add(Duration(days: 3)),
      duration: 90,
      interviewers: [1, 3],
      status: 'scheduled',
    ),
    Interview(
      id: 3,
      applicationId: 103,
      type: 'Phone',
      scheduledDate: DateTime.now().subtract(Duration(days: 2)),
      duration: 30,
      interviewers: [2],
      status: 'completed',
      rating: 4.2,
    ),
  ];

  String _selectedFilter = 'upcoming';

  @override
  Widget build(BuildContext context) {
    final filteredInterviews = _interviews.where((interview) {
      if (_selectedFilter == 'upcoming') {
        return interview.status == 'scheduled';
      } else if (_selectedFilter == 'completed') {
        return interview.status == 'completed';
      }
      return true;
    }).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/schedule-interview');
        },
        backgroundColor: AppColors.primaryRed,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interviews',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            SizedBox(height: 20),
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Upcoming', 'upcoming'),
                  SizedBox(width: 8),
                  _buildFilterChip('Completed', 'completed'),
                  SizedBox(width: 8),
                  _buildFilterChip('All', 'all'),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Interviews List
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredInterviews.length,
              itemBuilder: (context, index) {
                final interview = filteredInterviews[index];
                return _buildInterviewCard(interview);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: AppColors.primaryRed,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.darkText,
      ),
    );
  }

  Widget _buildInterviewCard(Interview interview) {
    final isCompleted = interview.status == 'completed';
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return GlassmorphicContainer(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Interview #${interview.id}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : AppColors.primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  interview.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.green : AppColors.primaryRed,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '${interview.type} Interview - ${interview.duration} minutes',
            style: TextStyle(fontSize: 14, color: AppColors.lightText),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: AppColors.mediumGray),
              SizedBox(width: 4),
              Text(
                dateFormat.format(interview.scheduledDate),
                style: TextStyle(fontSize: 12, color: AppColors.mediumGray),
              ),
              SizedBox(width: 16),
              Icon(Icons.access_time, size: 16, color: AppColors.mediumGray),
              SizedBox(width: 4),
              Text(
                timeFormat.format(interview.scheduledDate),
                style: TextStyle(fontSize: 12, color: AppColors.mediumGray),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (isCompleted && interview.rating != null) ...[
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber),
                SizedBox(width: 4),
                Text(
                  interview.rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (isCompleted) {
                      Navigator.pushNamed(
                        context,
                        '/interview-feedback',
                        arguments: interview,
                      );
                    } else {
                      // Join interview or view details
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryRed,
                    side: BorderSide(color: AppColors.primaryRed),
                  ),
                  child: Text(isCompleted ? 'View Feedback' : 'View Details'),
                ),
              ),
              SizedBox(width: 8),
              if (!isCompleted)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Join interview
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                    ),
                    child: Text('Join'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
