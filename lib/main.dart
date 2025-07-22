import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:smart_learning_application/const.dart';
import 'package:smart_learning_application/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'learning_style_page.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'home_page_visual.dart';
 // Ensure you have a signup_page.dart file
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Gemini.init(
    apiKey: 'AIzaSyCHfqH-esdz9cIc5chCF2_w4c0pO7O6iCk',
    enableDebugging: true,

  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduAi',
      theme: ThemeData(
        primarySwatch: Colors.blue,

      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,// Set LoginPage as the initial page
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/learning-style': (context) => QuizScreen(),// Ensure this points to your signup page
      },
    );
  }
}
