import 'package:flutter/material.dart';
import 'core/index_export.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '견심술',
      theme: AppTheme.lightTheme,
      routes: AppRoutes.routes,
      initialRoute: '/',
    );
  }
}