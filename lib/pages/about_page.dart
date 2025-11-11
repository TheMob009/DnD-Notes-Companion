import 'package:flutter/material.dart';
import 'feedback_page.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const _devName = 'Matías Ortega';
  static const _devEmail = 'maortega23@alumnos.utalca.cl';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: cs.primaryContainer,
                child: Icon(Icons.shield, color: cs.primary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'DnD Notes Companion',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'App para organizar notas de campañas TTRPG (D&D, Pathfinder, etc.). '
            'Permite separar por campaña, sesión y categoría, enlazar notas y adjuntar imágenes.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Desarrollador'),
              subtitle: const Text(_devName),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Contacto'),
              subtitle: const Text(_devEmail),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.rate_review),
            label: const Text('Tu opinión'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FeedbackPage(
                    developerEmail: _devEmail,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
