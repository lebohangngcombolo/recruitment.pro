import 'package:flutter/material.dart';
import 'package:recruitment_frontend/widgets/glassmorphic_container.dart';
import 'package:recruitment_frontend/widgets/gradient_button.dart';
import 'package:recruitment_frontend/utils/constants.dart';
import 'package:intl/intl.dart';

class ScheduleInterviewScreen extends StatefulWidget {
  const ScheduleInterviewScreen({super.key});

  @override
  _ScheduleInterviewScreenState createState() =>
      _ScheduleInterviewScreenState();
}

class _ScheduleInterviewScreenState extends State<ScheduleInterviewScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedType = 'video';
  int _selectedDuration = 60;
  final List<int> _selectedInterviewers = [];

  final List<Map<String, dynamic>> _interviewers = [
    {'id': 1, 'name': 'Sarah Johnson', 'role': 'Technical Manager'},
    {'id': 2, 'name': 'Mike Chen', 'role': 'Team Lead'},
    {'id': 3, 'name': 'Emily Davis', 'role': 'HR Manager'},
    {'id': 4, 'name': 'David Wilson', 'role': 'Senior Developer'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Interview'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GlassmorphicContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Interview Details', style: AppTextStyles.glassTitle),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      items: const [
                        DropdownMenuItem(
                          value: 'video',
                          child: Text('Video Call'),
                        ),
                        DropdownMenuItem(
                          value: 'onsite',
                          child: Text('Onsite'),
                        ),
                        DropdownMenuItem(
                          value: 'phone',
                          child: Text('Phone Call'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Interview Type',
                        prefixIcon: Icon(
                          Icons.video_call,
                          color: AppColors.primaryRed,
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedDuration,
                      items: [30, 45, 60, 90].map((duration) {
                        return DropdownMenuItem(
                          value: duration,
                          child: Text('$duration minutes'),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Duration',
                        prefixIcon: Icon(
                          Icons.access_time,
                          color: AppColors.primaryRed,
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedDuration = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Date Picker
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: AppColors.primaryRed,
                        ),
                      ),
                      controller: TextEditingController(
                        text: DateFormat('MMM dd, yyyy').format(_selectedDate),
                      ),
                      readOnly: true,
                      onTap: _selectDate,
                    ),
                    const SizedBox(height: 16),
                    // Time Picker
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Time',
                        prefixIcon: Icon(
                          Icons.access_time,
                          color: AppColors.primaryRed,
                        ),
                      ),
                      controller: TextEditingController(
                        text: _selectedTime.format(context),
                      ),
                      readOnly: true,
                      onTap: _selectTime,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GlassmorphicContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Interviewers',
                      style: AppTextStyles.glassTitle,
                    ),
                    const SizedBox(height: 16),
                    ..._interviewers.map((interviewer) {
                      return _buildInterviewerCheckbox(interviewer);
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              GradientButton(
                text: 'Schedule Interview',
                onPressed: _scheduleInterview,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInterviewerCheckbox(Map<String, dynamic> interviewer) {
    final isSelected = _selectedInterviewers.contains(interviewer['id']);
    return CheckboxListTile(
      title: Text(interviewer['name']),
      subtitle: Text(interviewer['role']),
      value: isSelected,
      onChanged: (selected) {
        setState(() {
          if (selected ?? false) {
            _selectedInterviewers.add(interviewer['id']);
          } else {
            _selectedInterviewers.remove(interviewer['id']);
          }
        });
      },
      activeColor: AppColors.primaryRed,
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _scheduleInterview() {
    if ((_formKey.currentState?.validate() ?? false) &&
        _selectedInterviewers.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Interview scheduled successfully!')),
      );
      Navigator.pop(context);
    } else if (_selectedInterviewers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one interviewer')),
      );
    }
  }
}

