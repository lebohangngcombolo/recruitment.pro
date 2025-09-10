import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recruitment_frontend/services/auth_service.dart';
import 'package:recruitment_frontend/widgets/glassmorphic_container.dart';
import 'package:recruitment_frontend/widgets/gradient_button.dart';
import 'package:recruitment_frontend/utils/constants.dart';
import 'package:recruitment_frontend/utils/validators.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE53935).withOpacity(0.1),
              Color(0xFFFF5252).withOpacity(0.1),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: 100),
              // 3D Icon
              Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(0.1),
                alignment: Alignment.center,
                child: Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: AppColors.primaryRed,
                ),
              ),
              SizedBox(height: 20),
              Text('Reset Password', style: AppTextStyles.glassTitle),
              SizedBox(height: 10),
              Text(
                _emailSent
                    ? 'Check your email for reset instructions'
                    : 'Enter your email to receive reset instructions',
                style: AppTextStyles.glassSubtitle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              if (!_emailSent) ...[
                GlassmorphicContainer(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(
                              Icons.email,
                              color: AppColors.primaryRed,
                            ),
                          ),
                          validator: (value) => Validators.email(value ?? ''),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 30),
                        GradientButton(
                          text: 'Send Reset Link',
                          onPressed: () {
                            if (!_isLoading) _handleResetRequest();
                          },
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                GlassmorphicContainer(
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, size: 60, color: Colors.green),
                      SizedBox(height: 20),
                      Text(
                        'Reset email sent successfully!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Please check your inbox and follow the instructions to reset your password.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.lightText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
                      GradientButton(
                        text: 'Back to Login',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleResetRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final success = await authService.forgotPassword(_emailController.text);

        if (success) {
          setState(() {
            _emailSent = true;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send reset email. Please try again.'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
