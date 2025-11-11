import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_controller.dart';
import 'about_page.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Preferencias')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _section('Apariencia'),
          Card(
            child: ListTile(
              title: const Text('Tema de la aplicación'),
              subtitle: Text(_themeLabel(settings.theme)),
              trailing: DropdownButton<AppThemeMode>(
                value: settings.theme,
                onChanged: (v) => v == null ? null : settings.setTheme(v),
                items: AppThemeMode.values
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(_themeLabel(e)),
                        ))
                    .toList(),
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Tamaño de texto'),
                    subtitle: Text('Ajusta el tamaño global dentro de la app'),
                  ),
                  Slider(
                    value: settings.textScale,
                    min: 0.85,
                    max: 1.30,
                    divisions: 9,
                    label: settings.textScale.toStringAsFixed(2),
                    onChanged: (v) => settings.setTextScale(v),
                  ),
                  Transform.scale(
                    scale: settings.textScale,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Vista previa del texto',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          _section('Notas'),
          Card(
            child: ListTile(
              title: const Text('Orden de las notas'),
              subtitle: Text(_sortLabel(settings.sort)),
              trailing: DropdownButton<SortOrder>(
                value: settings.sort,
                onChanged: (v) => v == null ? null : settings.setSort(v),
                items: SortOrder.values
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(_sortLabel(e)),
                        ))
                    .toList(),
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Buscar también en la descripción'),
            subtitle: const Text('Si está desactivado, busca solo por título'),
            value: settings.searchInDescription,
            onChanged: (v) => settings.setSearchInDescription(v),
            activeColor: scheme.primary,
          ),

          // Sección Acerca de
          _section('Acerca de'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Acerca de la aplicación'),
              subtitle: const Text('Información del proyecto y enviar tu opinión'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
        child: Text(
          t,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      );

  String _themeLabel(AppThemeMode m) =>
      m == AppThemeMode.light ? 'Claro' : 'Oscuro';

  String _sortLabel(SortOrder s) =>
      s == SortOrder.titleAsc ? 'Alfabético (A–Z)' : 'Alfabético (Z–A)';
}
