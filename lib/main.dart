import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const DocScanApp());
}

class DocScanApp extends StatelessWidget {
  const DocScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocScan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      home: const HomeScreen(),
    );
  }
}
