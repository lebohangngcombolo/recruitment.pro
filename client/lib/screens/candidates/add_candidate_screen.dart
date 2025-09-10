import 'package:flutter/material.dart';
import 'package:recruitment_frontend/widgets/glassmorphic_container.dart';
import 'package:recruitment_frontend/widgets/gradient_button.dart';
import 'package:recruitment_frontend/utils/constants.dart';
import 'package:recruitment_frontend/utils/validators.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddCandidateScreen extends StatefulWidget {
  const AddCandidateScreen({super.key});

  @override
  _AddCandidateScreenState createState() => _AddCandidateScreenState();
}

class _AddCandidateScreenState extends State<AddCandidateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _companyController = TextEditingController();
  final _titleController = TextEditingController();
  final _experienceController = TextEditingController();
  final _summaryController = TextEditingController();

  File? _cvFile;
  bool _consentGiven = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Candidate'),
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
                    Text(
                      'Personal Information',
                      style: AppTextStyles.glassTitle,
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              labelText: 'First Name',
                            ),
                            validator: Validators.requiredField,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(labelText: 'Last Name'),
                            validator: Validators.requiredField,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(labelText: 'Location'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              GlassmorphicContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Professional Information',
                      style: AppTextStyles.glassTitle,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _companyController,
                      decoration: InputDecoration(labelText: 'Current Company'),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Current Title'),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _experienceController,
                      decoration: InputDecoration(
                        labelText: 'Total Experience (years)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _summaryController,
                      decoration: InputDecoration(
                        labelText: 'Professional Summary',
                      ),
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
                    Text('CV Upload', style: AppTextStyles.glassTitle),
                    SizedBox(height: 20),
                    _buildCVUploadSection(),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _consentGiven,
                          onChanged: (value) {
                            setState(() {
                              _consentGiven = value ?? false;
                            });
                          },
                          activeColor: AppColors.primaryRed,
                        ),
                        Expanded(
                          child: Text(
                            'I consent to the processing of my personal data for recruitment purposes',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              GradientButton(
                text: 'Add Candidate',
                onPressed: _isLoading ? () {} : _addCandidate,
                isLoading: _isLoading,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCVUploadSection() {
    return Column(
      children: [
        if (_cvFile != null) ...[
          ListTile(
            leading: Icon(Icons.description, color: AppColors.primaryRed),
            title: Text(_cvFile!.path.split('/').last),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: AppColors.primaryRed),
              onPressed: () {
                setState(() {
                  _cvFile = null;
                });
              },
            ),
          ),
          SizedBox(height: 16),
        ],
        ElevatedButton.icon(
          onPressed: _pickCVFile,
          icon: Icon(Icons.upload_file),
          label: Text('Upload CV'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
          ),
        ),
      ],
    );
  }

  Future<void> _pickCVFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _cvFile = File(pickedFile.path);
      });
    }
  }

  void _addCandidate() {
    // Use null-aware call with ?? false
    if ((_formKey.currentState?.validate() ?? false) && _consentGiven) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
      });
    } else if (!_consentGiven) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please consent to data processing')),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _companyController.dispose();
    _titleController.dispose();
    _experienceController.dispose();
    _summaryController.dispose();
    super.dispose();
  }
}
