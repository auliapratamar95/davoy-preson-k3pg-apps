import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/attendance_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/history_provider.dart';
import 'providers/requests_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => RequestsProvider()),
      ],
      child: const DavoyApp(),
    ),
  );
}

class DavoyApp extends StatelessWidget {
  const DavoyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return MaterialApp(
      title: 'DAVOY',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: auth.isAuthenticated ? const MainLayout() : const LoginScreen(),
    );
  }
}
