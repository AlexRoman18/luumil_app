
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luumil_app/config/router/gemini/app_router.dart';
import 'package:luumil_app/config/theme/gemini/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); 
    

  await dotenv.load(fileName: ".env");
  AppTheme.setSistemUIOverlayStyle(isDarkmode: true);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Luumil App',
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
