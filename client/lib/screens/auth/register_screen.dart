import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recruitment_frontend/services/auth_service.dart';
import 'package:recruitment_frontend/widgets/glassmorphic_container.dart';
import 'package:recruitment_frontend/widgets/gradient_button.dart';
import 'package:recruitment_frontend/utils/constants.dart';
import 'package:recruitment_frontend/utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'recruiter';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFE53935).withOpacity(0.1),
              const Color(0xFFFF5252).withOpacity(0.1),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // 3D Logo/Title
              Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(0.1),
                alignment: Alignment.center,
                child: Text(
                  'Join Us',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryRed,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Create your account to get started',
                style: AppTextStyles.glassSubtitle,
              ),
              const SizedBox(height: 40),

              GlassmorphicContainer(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text('Sign Up', style: AppTextStyles.glassTitle),
                      const SizedBox(height: 30),

                      // Name Fields
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'First Name',
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: AppColors.primaryRed,
                                ),
                              ),
                              validator: (value) =>
                                  Validators.requiredField(value ?? ''),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Last Name',
                              ),
                              validator: (value) =>
                                  Validators.requiredField(value ?? ''),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(
                            Icons.email,
                            color: AppColors.primaryRed,
                          ),
                        ),
                        validator: (value) => Validators.email(value ?? ''),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),

                      // Role Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        items: const [
                          DropdownMenuItem(
                            value: 'recruiter',
                            child: Text('Recruiter'),
                          ),
                          DropdownMenuItem(
                            value: 'hiring_manager',
                            child: Text('Hiring Manager'),
                          ),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Administrator'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          prefixIcon: Icon(
                            Icons.work,
                            color: AppColors.primaryRed,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value ?? 'recruiter';
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: AppColors.primaryRed,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.primaryRed,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) => Validators.password(value ?? ''),
                        obscureText: _obscurePassword,
                      ),
                      const SizedBox(height: 20),

                      // Confirm Password
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: AppColors.primaryRed,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.primaryRed,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) => Validators.confirmPassword(
                          value ?? '',
                          _passwordController.text,
                        ),
                        obscureText: _obscureConfirmPassword,
                      ),
                      const SizedBox(height: 30),

                      // Register Button
                      GradientButton(
                        text: 'Create Account',
                        onPressed: () {
                          if (!_isLoading) {
                            _handleRegister();
                          }
                        },
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 20),

                      // Sign In Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? "),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: AppColors.primaryRed,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final success = await authService.register(
          _emailController.text,
          _passwordController.text,
          _firstNameController.text,
          _lastNameController.text,
          _selectedRole,
        );

        if (success) {
          Navigator.pushNamed(
            context,
            '/verify-email',
            arguments: _emailController.text,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration failed. Please try again.'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration error: ${e.toString()}')),
        );
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
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
