import 'package:flutter/material.dart';
import 'package:recruitment_frontend/widgets/glassmorphic_container.dart';
import 'package:recruitment_frontend/widgets/gradient_button.dart';
import 'package:recruitment_frontend/utils/constants.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class InterviewFeedbackScreen extends StatefulWidget {
  const InterviewFeedbackScreen({super.key});

  @override
  _InterviewFeedbackScreenState createState() =>
      _InterviewFeedbackScreenState();
}

class _InterviewFeedbackScreenState extends State<InterviewFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  double _technicalRating = 0;
  double _communicationRating = 0;
  double _culturalFitRating = 0;
  bool _recommendHire = false;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interview Feedback'),
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
                    Text('Overall Rating', style: AppTextStyles.glassTitle),
                    SizedBox(height: 20),
                    Center(
                      child: RatingBar.builder(
                        initialRating: 0,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 40,
                        itemBuilder: (context, _) =>
                            Icon(Icons.star, color: Colors.amber),
                        onRatingUpdate: (rating) {
                          // Optionally compute average of other ratings
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              GlassmorphicContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Detailed Ratings', style: AppTextStyles.glassTitle),
                    SizedBox(height: 20),
                    _buildRatingCategory(
                      'Technical Skills',
                      _technicalRating,
                      (rating) {
                        setState(() {
                          _technicalRating = rating;
                        });
                      },
                    ),
                    _buildRatingCategory(
                      'Communication',
                      _communicationRating,
                      (rating) {
                        setState(() {
                          _communicationRating = rating;
                        });
                      },
                    ),
                    _buildRatingCategory(
                      'Cultural Fit',
                      _culturalFitRating,
                      (rating) {
                        setState(() {
                          _culturalFitRating = rating;
                        });
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
                    Text('Feedback Comments', style: AppTextStyles.glassTitle),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _feedbackController,
                      decoration: InputDecoration(
                        labelText: 'Detailed Feedback',
                        hintText:
                            'Enter your observations and comments about the interview...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please provide feedback';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          'Recommend for hire',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        Switch(
                          value: _recommendHire,
                          onChanged: (value) {
                            setState(() {
                              _recommendHire = value;
                            });
                          },
                          activeColor: AppColors.primaryRed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              GradientButton(
  text: 'Submit Feedback',
  onPressed: () {
    if (!_isSubmitting) _submitFeedback();
  },
  isLoading: _isSubmitting,
),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingCategory(
    String title,
    double rating,
    ValueChanged<double> onRatingUpdate,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          RatingBar.builder(
            initialRating: rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 30,
            itemPadding: EdgeInsets.symmetric(horizontal: 2),
            itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: onRatingUpdate,
          ),
          SizedBox(height: 4),
          Text(
            rating == 0 ? 'Not rated' : rating.toStringAsFixed(1),
            style: TextStyle(fontSize: 14, color: AppColors.mediumGray),
          ),
        ],
      ),
    );
  }

  void _submitFeedback() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      // Simulate API call
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Feedback submitted successfully!')),
        );
        Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}
