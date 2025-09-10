import 'package:flutter/material.dart';
import 'package:recruitment_frontend/widgets/glassmorphic_container.dart';
import 'package:recruitment_frontend/utils/constants.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  _AvailabilityScreenState createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  final Map<String, List<TimeSlot>> _availability = {
    'monday': [],
    'tuesday': [],
    'wednesday': [],
    'thursday': [],
    'friday': [],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Availability'),
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
                    'Set Your Availability',
                    style: AppTextStyles.glassTitle,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Define your available time slots for interviews. Candidates will be able to book interviews during these times.',
                    style: TextStyle(fontSize: 14, color: AppColors.lightText),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ..._availability.keys.map((day) {
              return _buildDayAvailability(day);
            }),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveAvailability,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text('Save Availability'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDayAvailability(String day) {
    final daySlots = _availability[day];
    return GlassmorphicContainer(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _capitalize(day),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 12),
          ...(daySlots ?? []).map((slot) {
            return _buildTimeSlot(slot, day);
          }),
          SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _addTimeSlot(day),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryRed,
              side: BorderSide(color: AppColors.primaryRed),
            ),
            child: Text('Add Time Slot'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(TimeSlot slot, String day) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.access_time, color: AppColors.primaryRed, size: 20),
      title: Text('${slot.start} - ${slot.end}'),
      trailing: IconButton(
        icon: Icon(Icons.delete, color: AppColors.primaryRed, size: 20),
        onPressed: () => _removeTimeSlot(day, slot),
      ),
    );
  }

  void _addTimeSlot(String day) {
    setState(() {
      _availability[day]?.add(TimeSlot(start: '09:00', end: '10:00'));
    });
  }

  void _removeTimeSlot(String day, TimeSlot slot) {
    setState(() {
      _availability[day]?.remove(slot);
    });
  }

  void _saveAvailability() {
    // Save availability logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Availability saved successfully!')));
    Navigator.pop(context);
  }

  String _capitalize(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }
}

class TimeSlot {
  final String start;
  final String end;

  TimeSlot({required this.start, required this.end});
}
