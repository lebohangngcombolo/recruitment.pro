import 'package:flutter/material.dart';
import 'package:recruitment_frontend/widgets/glassmorphic_container.dart';
import 'package:recruitment_frontend/utils/constants.dart';
import 'package:recruitment_frontend/screens/candidates/candidates_list_screen.dart';
import 'package:recruitment_frontend/screens/interviews/interviews_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

// Added widget definition for RequisitionsListScreen
class RequisitionsListScreen extends StatelessWidget {
  const RequisitionsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Requisitions List Screen'));
  }
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    OverviewScreen(),
    RequisitionsListScreen(),
    CandidatesListScreen(),
    InterviewsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: AppColors.primaryRed),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person, color: AppColors.primaryRed),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: GlassmorphicContainer(
        height: 70,
        padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.work, 'Jobs', 1),
            _buildNavItem(Icons.people, 'Candidates', 2),
            _buildNavItem(Icons.calendar_today, 'Interviews', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primaryRed : AppColors.mediumGray,
            size: 24,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? AppColors.primaryRed : AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }
}

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Overview', style: Theme.of(context).textTheme.displayMedium),
          SizedBox(height: 20),
          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Open Positions',
                  '12',
                  Icons.work_outline,
                  AppColors.primaryRed,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Candidates',
                  '84',
                  Icons.people_outline,
                  Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Interviews',
                  '23',
                  Icons.calendar_today,
                  Colors.green,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Assessments',
                  '45',
                  Icons.assignment,
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          SizedBox(height: 16),
          GlassmorphicContainer(
            child: Column(
              children: [
                _buildActivityItem('New candidate applied', '2 min ago'),
                _buildActivityItem('Interview scheduled', '1 hour ago'),
                _buildActivityItem('Position filled', '3 hours ago'),
                _buildActivityItem('Assessment completed', '5 hours ago'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassmorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: AppColors.lightText),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryRed.withOpacity(0.2),
        child: Icon(Icons.notifications, size: 20, color: AppColors.primaryRed),
      ),
      title: Text(title, style: TextStyle(fontSize: 14)),
      subtitle: Text(
        time,
        style: TextStyle(fontSize: 12, color: AppColors.lightText),
      ),
    );
  }
}
