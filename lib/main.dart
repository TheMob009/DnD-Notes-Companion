import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DnDNotesApp());
}

class DnDNotesApp extends StatelessWidget {
  const DnDNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DnD Notes Companion',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system, // usa el modo del dispositivo (puedes forzar .dark)
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
