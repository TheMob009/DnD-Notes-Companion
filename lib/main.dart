import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'pages/home_page.dart';
import 'services/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = SettingsController();
  await settings.load();

  runApp(
    ChangeNotifierProvider.value(
      value: settings,
      child: const DnDNotesApp(),
    ),
  );
}

class DnDNotesApp extends StatelessWidget {
  const DnDNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final themeMode =
        settings.theme == AppThemeMode.light ? ThemeMode.light : ThemeMode.dark;

    return MaterialApp(
      title: 'DnD Notes Companion',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      builder: (ctx, child) {
        // Aplica el escalado de texto global
        final media = MediaQuery.of(ctx);
        return MediaQuery(
          data: media.copyWith(textScaler: TextScaler.linear(settings.textScale)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
