import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:google_fonts/google_fonts.dart';

// importar pagina
import 'pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // buena práctica con splash (idk)
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = Logger();
    logger.d("Logger está dando cara!");

    return MaterialApp(
      title: 'DnD Notes Companion',
      theme: _buildAppTheme(),
      home: const HomePage(), // el splash nativo se muestra solo antes
      debugShowCheckedModeBanner: false,
    );
  }
}

ThemeData _buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 129, 26, 189),
      brightness: Brightness.dark,
    ),
  );

  final textThemeBody = GoogleFonts.robotoTextTheme(base.textTheme);

  return base.copyWith(
    textTheme: textThemeBody,
    appBarTheme: AppBarTheme(
      backgroundColor: base.colorScheme.inversePrimary,
      foregroundColor: base.colorScheme.onPrimaryContainer,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textThemeBody.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: base.colorScheme.primary,
      foregroundColor: base.colorScheme.onPrimary,
      shape: const StadiumBorder(),
      elevation: 2,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
