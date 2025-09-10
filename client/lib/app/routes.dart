import 'package:flutter/material.dart';
import 'package:recruitment_frontend/screens/auth/login_screen.dart' as auth;
import 'package:recruitment_frontend/screens/auth/register_screen.dart';
import 'package:recruitment_frontend/screens/auth/verify_email_screen.dart';
import 'package:recruitment_frontend/screens/auth/reset_password_screen.dart';
import 'package:recruitment_frontend/screens/dashboard/dashboard_screen.dart';
import 'package:recruitment_frontend/screens/requisitions/create_requisition_screen.dart';
import 'package:recruitment_frontend/screens/requisitions/requisition_detail_screen.dart';
import 'package:recruitment_frontend/screens/candidates/candidates_list_screen.dart';
import 'package:recruitment_frontend/screens/candidates/candidate_detail_screen.dart';
import 'package:recruitment_frontend/screens/candidates/add_candidate_screen.dart';
import 'package:recruitment_frontend/screens/assessments/assessment_packs_screen.dart';
import 'package:recruitment_frontend/screens/assessments/take_assessment_screen.dart';
import 'package:recruitment_frontend/screens/interviews/interviews_screen.dart';
import 'package:recruitment_frontend/screens/interviews/schedule_interview_screen.dart';
import 'package:recruitment_frontend/screens/profile/profile_screen.dart';
import 'package:recruitment_frontend/models/requisition_model.dart';
import 'package:recruitment_frontend/models/candidate_model.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/login':
        return MaterialPageRoute(builder: (_) => auth.LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case '/verify-email':
        return MaterialPageRoute(builder: (_) => VerifyEmailScreen());
      case '/reset-password':
        return MaterialPageRoute(builder: (_) => ResetPasswordScreen());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => DashboardScreen());
      case '/create-requisition':
        return MaterialPageRoute(builder: (_) => CreateRequisitionScreen());
      
      case '/requisition-detail':
        final requisition = settings.arguments;
        if (requisition is Requisition) {
          return MaterialPageRoute(
            builder: (_) => RequisitionDetailScreen(requisition: requisition),
          );
        }
        return _errorRoute('Invalid or missing requisition object.');

      case '/candidates':
        return MaterialPageRoute(builder: (_) => CandidatesListScreen());

      case '/candidate-detail':
  final candidate = settings.arguments;
  if (candidate is Candidate) {
    return MaterialPageRoute(
      builder: (_) => CandidateDetailScreen(), // no parameters
      settings: RouteSettings(arguments: candidate), // pass it via arguments
    );
  }
  return _errorRoute('Invalid or missing candidate object.');



      case '/add-candidate':
        return MaterialPageRoute(builder: (_) => AddCandidateScreen());
      case '/assessments':
        return MaterialPageRoute(builder: (_) => AssessmentPacksScreen());
      case '/take-assessment':
        return MaterialPageRoute(builder: (_) => TakeAssessmentScreen());
      case '/interviews':
        return MaterialPageRoute(builder: (_) => InterviewsScreen());
      case '/schedule-interview':
        return MaterialPageRoute(builder: (_) => ScheduleInterviewScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => ProfileScreen());

      default:
        return _errorRoute('No route defined for ${settings.name}');
    }
  }

  static MaterialPageRoute _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(child: Text(message)),
      ),
    );
  }
}
