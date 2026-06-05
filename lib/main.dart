import 'package:blok34_mobile/providers/weather_provider.dart';
import 'package:blok34_mobile/screens/auth/login_screen.dart';
import 'package:blok34_mobile/screens/home_screen.dart';
import 'package:blok34_mobile/screens/main_screen.dart';
import 'package:blok34_mobile/services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => WeatherProvider(),
            ),
          ],
          child: const MyApp()));

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blok34',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      // start here
      //  home: LoginScreen(authService: authService),
          home: MainScreen(),
    );
  }
}

// temporary placeholder

