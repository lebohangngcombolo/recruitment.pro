import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recruitment_frontend/services/auth_service.dart';
import 'package:recruitment_frontend/widgets/glassmorphic_container.dart';
import 'package:recruitment_frontend/utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, dynamic> _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.getUser();
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: AppColors.primaryRed),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: _user == null
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header
                  GlassmorphicContainer(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primaryRed.withOpacity(
                            0.2,
                          ),
                          child: Text(
                            '${_user['first_name'][0]}${_user['last_name'][0]}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryRed,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          '${_user['first_name']} ${_user['last_name']}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _user['email'],
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.lightText,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _user['role'].toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Profile Actions
                  GlassmorphicContainer(
                    child: Column(
                      children: [
                        _buildProfileAction(
                          Icons.calendar_today,
                          'Availability',
                          'Set your interview availability',
                          () {
                            Navigator.pushNamed(context, '/availability');
                          },
                        ),
                        _buildProfileAction(
                          Icons.notifications,
                          'Notifications',
                          'Manage notification preferences',
                          () {},
                        ),
                        _buildProfileAction(
                          Icons.security,
                          'Privacy & Security',
                          'Manage your account security',
                          () {},
                        ),
                        _buildProfileAction(
                          Icons.help,
                          'Help & Support',
                          'Get help with the application',
                          () {},
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Statistics
                  GlassmorphicContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Activity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildStatItem('Interviews Conducted', '24'),
                        _buildStatItem('Candidates Reviewed', '156'),
                        _buildStatItem('Requisitions Created', '12'),
                        _buildStatItem('Average Rating', '4.7/5'),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  // Logout Button
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Text('Log Out'),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileAction(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryRed),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right, color: AppColors.mediumGray),
      onTap: onTap,
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
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

  void _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }
}
