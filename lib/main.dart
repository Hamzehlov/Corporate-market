import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

const Color primaryColor = Color(0xFF1E88E5); // أزرق مميز
const Color accentColor = Color(0xFFFFC107); // أصفر للتأكيد

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light; // الوضع الحالي

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Corporate Market',
      theme: ThemeData(
        primaryColor: primaryColor,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        fontFamily: 'Cairo',
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: primaryColor,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey.shade900,
        fontFamily: 'Cairo',
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      themeMode: _themeMode, // نستخدم الوضع الحالي
      home: HomePage(toggleTheme: _toggleTheme), // تمرير دالة التبديل
    );
  }
}
