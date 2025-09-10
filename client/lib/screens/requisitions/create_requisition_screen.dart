import 'package:flutter/material.dart';
import 'package:recruitment_frontend/widgets/glassmorphic_container.dart';
import 'package:recruitment_frontend/widgets/gradient_button.dart';
import 'package:recruitment_frontend/utils/constants.dart';

class CreateRequisitionScreen extends StatefulWidget {
  const CreateRequisitionScreen({super.key});

  @override
  _CreateRequisitionScreenState createState() =>
      _CreateRequisitionScreenState();
}

class _CreateRequisitionScreenState extends State<CreateRequisitionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _departmentController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _minExperienceController = TextEditingController();
  final _locationController = TextEditingController();

  final List<Map<String, dynamic>> _requiredSkills = [];
  final List<Map<String, dynamic>> _knockoutRules = [];
  final Map<String, dynamic> _weightings = {'cv': 60, 'assessment': 40};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Requisition'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GlassmorphicContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Basic Information', style: AppTextStyles.glassTitle),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Job Title'),
                      validator: (value) =>
                          value?.isEmpty == true ? 'Please enter a job title' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _departmentController,
                      decoration: InputDecoration(labelText: 'Department'),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _requirementsController,
                      decoration: InputDecoration(labelText: 'Requirements'),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              GlassmorphicContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Requirements', style: AppTextStyles.glassTitle),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _minExperienceController,
                      decoration: InputDecoration(
                        labelText: 'Minimum Experience (years)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(labelText: 'Location'),
                    ),
                    SizedBox(height: 16),
                    _buildSkillsSection(),
                    SizedBox(height: 16),
                    _buildKnockoutRulesSection(),
                  ],
                ),
              ),
              SizedBox(height: 20),
              GlassmorphicContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Scoring Weightings', style: AppTextStyles.glassTitle),
                    SizedBox(height: 20),
                    _buildWeightingSlider('CV Match', 'cv', _weightings['cv']),
                    SizedBox(height: 16),
                    _buildWeightingSlider(
                      'Assessment',
                      'assessment',
                      _weightings['assessment'],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              GradientButton(
                text: 'Create Requisition',
                onPressed: _createRequisition,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Required Skills', style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        ..._requiredSkills.map((skill) => _buildSkillItem(skill)),
        SizedBox(height: 8),
        TextButton(
          onPressed: _addSkill,
          child: Text(
            '+ Add Skill',
            style: TextStyle(color: AppColors.primaryRed),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillItem(Map<String, dynamic> skill) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(skill['name']),
      subtitle: Text('Min. ${skill['minYears']} years'),
      trailing: IconButton(
        icon: Icon(Icons.delete, color: AppColors.primaryRed),
        onPressed: () => _removeSkill(skill),
      ),
    );
  }

  Widget _buildKnockoutRulesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Knockout Rules', style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        ..._knockoutRules.map((rule) => _buildRuleItem(rule)),
        SizedBox(height: 8),
        TextButton(
          onPressed: _addKnockoutRule,
          child: Text(
            '+ Add Rule',
            style: TextStyle(color: AppColors.primaryRed),
          ),
        ),
      ],
    );
  }

  Widget _buildRuleItem(Map<String, dynamic> rule) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${rule['type']}: ${rule['value']}'),
      trailing: IconButton(
        icon: Icon(Icons.delete, color: AppColors.primaryRed),
        onPressed: () => _removeRule(rule),
      ),
    );
  }

  Widget _buildWeightingSlider(String label, String key, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.round()}%'),
        Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: 10,
          activeColor: AppColors.primaryRed,
          inactiveColor: AppColors.lightGray,
          onChanged: (newValue) {
            setState(() {
              _weightings[key] = newValue;
              // Adjust the other weighting to maintain total of 100%
              String otherKey = key == 'cv' ? 'assessment' : 'cv';
              _weightings[otherKey] = 100 - newValue;
            });
          },
        ),
      ],
    );
  }

  void _addSkill() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Skill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(decoration: InputDecoration(labelText: 'Skill Name')),
            TextFormField(
              decoration: InputDecoration(labelText: 'Minimum Years'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Add skill logic
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addKnockoutRule() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Knockout Rule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField(
              items: [
                'Skill',
                'Experience',
                'Certification',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              decoration: InputDecoration(labelText: 'Rule Type'),
              onChanged: (value) {},
            ),
            TextFormField(decoration: InputDecoration(labelText: 'Value')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Add rule logic
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeSkill(Map<String, dynamic> skill) {
    setState(() {
      _requiredSkills.remove(skill);
    });
  }

  void _removeRule(Map<String, dynamic> rule) {
    setState(() {
      _knockoutRules.remove(rule);
    });
  }

  void _createRequisition() {
    if (_formKey.currentState?.validate() ?? false) {
      // Create requisition logic
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _departmentController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _minExperienceController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
