import 'package:flutter/material.dart';
import 'create_category.dart';
import 'create_note.dart';
import 'note_detail.dart';

class CampaignDashboardPage extends StatelessWidget {
  final String campaignName;
  final IconData campaignIcon;

  const CampaignDashboardPage({
    super.key,
    required this.campaignName,
    this.campaignIcon = Icons.shield,
  });

  @override
  Widget build(BuildContext context) {
    // Categorías predefinidas
    final Map<String, List<Map<String, dynamic>>> notesByCategory = {
      "Historia/Sesión": [
        {"title": "Sesión 1", "description": "Introducción a la aventura", "icon": Icons.menu_book},
      ],
      "Personajes": [
        {"title": "Arthas", "description": "Paladín caído en desgracia", "icon": Icons.person},
      ],
      "Ciudades": [
        {"title": "Waterdeep", "description": "Ciudad de los esplendores", "icon": Icons.location_city},
      ],
      "Lugares": [
        {"title": "Castillo Ravenloft", "description": "Fortaleza de Strahd", "icon": Icons.castle},
      ],
      "Objetos": [
        {"title": "Escudo Solar", "description": "Arma legendaria contra vampiros", "icon": Icons.shield},
      ],
      "Misiones": [
        {"title": "Derrotar a Strahd", "description": "Liberar Barovia de su tiranía", "icon": Icons.flag},
      ],
    };

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(campaignIcon, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                campaignName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: "Crear Categoría",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateCategoryPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: notesByCategory.entries.map((entry) {
          final category = entry.key;
          final notes = entry.value;

          return ExpansionTile(
            title: Text(
              category,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: notes.map((note) {
              return ListTile(
                leading: Icon(note["icon"] as IconData),
                title: Text(note["title"] as String),
                subtitle: Text(note["description"] as String),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteDetailPage(
                        noteTitle: note["title"] as String,
                        noteDescription: note["description"] as String,
                        noteIcon: note["icon"] as IconData,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateNotePage(),
            ),
          );
        },
        icon: const Icon(Icons.note_add),
        label: const Text("Crear Nota"),
      ),
    );
  }
}
