import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryRed = Color(0xFFE53935);
  static const Color accentRed = Color(0xFFFF5252);
  static const Color darkRed = Color(0xFFB71C1C);
  static const Color backgroundWhite = Color(0xFFFAFAFA);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFEEEEEE);
  static const Color mediumGray = Color(0xFF9E9E9E);
  static const Color darkText = Color(0xFF212121);
  static const Color lightText = Color(0xFF757575);
}

class AppGradients {
  static Gradient redGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryRed, AppColors.accentRed],
  );

  static Gradient glassmorphism = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
  );
}

class AppShadows {
  static List<BoxShadow> glassmorphism = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 20,
      spreadRadius: 2,
      offset: Offset(0, 10),
    ),
  ];

  static List<BoxShadow> button = [
    BoxShadow(
      color: AppColors.primaryRed.withOpacity(0.3),
      blurRadius: 10,
      spreadRadius: 2,
      offset: Offset(0, 5),
    ),
  ];
}

class AppTextStyles {
  static TextStyle glassTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.darkText,
    letterSpacing: 1.2,
  );

  static TextStyle glassSubtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.lightText,
    letterSpacing: 0.5,
  );
}

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String resetPassword = '/reset-password';
  static const String dashboard = '/dashboard';
  static const String requisitions = '/requisitions';
  static const String createRequisition = '/create-requisition';
  static const String requisitionDetail = '/requisition-detail';
  static const String candidates = '/candidates';
  static const String candidateDetail = '/candidate-detail';
  static const String addCandidate = '/add-candidate';
  static const String assessments = '/assessments';
  static const String takeAssessment = '/take-assessment';
  static const String interviews = '/interviews';
  static const String scheduleInterview = '/schedule-interview';
  static const String profile = '/profile';
}
