import 'package:flutter/material.dart';
import 'package:recruitment_frontend/widgets/glassmorphic_container.dart';
import 'package:recruitment_frontend/utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _darkMode = false;
  String _language = 'english';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            GlassmorphicContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Settings',
                    style: AppTextStyles.glassTitle,
                  ),
                  SizedBox(height: 20),
                  SwitchListTile(
                    title: Text('Enable Notifications'),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    activeColor: AppColors.primaryRed,
                  ),
                  SwitchListTile(
                    title: Text('Email Notifications'),
                    value: _emailNotifications,
                    onChanged: (value) {
                      setState(() {
                        _emailNotifications = value;
                      });
                    },
                    activeColor: AppColors.primaryRed,
                  ),
                  SwitchListTile(
                    title: Text('Push Notifications'),
                    value: _pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        _pushNotifications = value;
                      });
                    },
                    activeColor: AppColors.primaryRed,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            GlassmorphicContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Appearance', style: AppTextStyles.glassTitle),
                  SizedBox(height: 20),
                  SwitchListTile(
                    title: Text('Dark Mode'),
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() {
                        _darkMode = value;
                      });
                    },
                    activeColor: AppColors.primaryRed,
                  ),
                  ListTile(
                    title: Text('Language'),
                    subtitle: Text('English'),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColors.mediumGray,
                    ),
                    onTap: () {
                      _showLanguageDialog();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            GlassmorphicContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Account Settings', style: AppTextStyles.glassTitle),
                  SizedBox(height: 20),
                  ListTile(
                    leading: Icon(Icons.lock, color: AppColors.primaryRed),
                    title: Text('Change Password'),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColors.mediumGray,
                    ),
                    onTap: () {
                      // Navigate to change password screen
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.security, color: AppColors.primaryRed),
                    title: Text('Privacy & Data'),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColors.mediumGray,
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.delete, color: AppColors.primaryRed),
                    title: Text('Delete Account'),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColors.mediumGray,
                    ),
                    onTap: () {
                      _showDeleteAccountDialog();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text('Save Settings'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption('English', 'english'),
              _buildLanguageOption('Spanish', 'spanish'),
              _buildLanguageOption('French', 'french'),
              _buildLanguageOption('German', 'german'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String name, String value) {
    return ListTile(
      title: Text(name),
      trailing: _language == value
          ? Icon(Icons.check, color: AppColors.primaryRed)
          : null,
      onTap: () {
        setState(() {
          _language = value;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Delete account logic
                Navigator.pop(context);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: AppColors.primaryRed),
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveSettings() {
    // Save settings logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Settings saved successfully!')));
    Navigator.pop(context);
  }
}
