import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // ← これを追加
import 'package:flutter/services.dart';
import 'views/main_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    HapticFeedback.mediumImpact();
    setState(() => _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        // const を外してエラーを回避
        cupertinoOverrideTheme: CupertinoThemeData(brightness: Brightness.light, primaryColor: CupertinoColors.activeBlue),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: CupertinoColors.black,
        cupertinoOverrideTheme: CupertinoThemeData(brightness: Brightness.dark, primaryColor: CupertinoColors.activeBlue),
      ),
      home: MainNavigation(onThemeToggle: _toggleTheme, isDark: _themeMode == ThemeMode.dark),
    );
  }
}