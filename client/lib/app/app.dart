import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recruitment_frontend/services/auth_service.dart';
import 'package:recruitment_frontend/services/socket_service.dart';
import 'package:recruitment_frontend/app/routes.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final AuthService _authService = AuthService();
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize socket connection if user is logged in
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      final token = await _authService.getToken();
      _socketService.connect(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => _authService),
        Provider<SocketService>(create: (_) => _socketService),
      ],
      child: MaterialApp(
        title: 'Recruitment Pro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFFE53935),
            secondary: const Color(0xFFFF5252),
          ),
          scaffoldBackgroundColor: const Color(0xFFFAFAFA),
          fontFamily: 'Poppins',
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
            displayMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Color(0xFF212121),
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Color(0xFF757575),
            ),
          ),
        ),
        onGenerateRoute: AppRoutes.generateRoute,
        initialRoute: '/',
      ),
    );
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}
