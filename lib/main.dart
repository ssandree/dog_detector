import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/index_export.dart';
import 'providers/pet_providers.dart';
import 'providers/alarm_providers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PetProvider()),
        ChangeNotifierProvider(create: (_) => AlarmProvider()),
      ],
      child: MaterialApp(
        title: '견심술',
        theme: AppTheme.lightTheme,
        routes: AppRoutes.routes,
        initialRoute: '/',
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
