import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:plan2shop/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Plan2ShopApp());
}

class Plan2ShopApp extends StatelessWidget {
  const Plan2ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plan2Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: const SplashScreen(),
    );
  }
}
