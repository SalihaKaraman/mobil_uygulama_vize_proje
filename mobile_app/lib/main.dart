import 'package:flutter/material.dart';
import 'screens/person_list_screen.dart';

void main() {
  runApp(const PersonManagementApp());
}

/// Uygulamanın Kök Widget'ı
class PersonManagementApp extends StatelessWidget {
  const PersonManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kişi Yönetim Sistemi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
      ),
      home: const PersonListScreen(),
    );
  }
}
