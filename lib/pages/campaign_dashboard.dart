import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'note_detail.dart';
import 'create_note.dart';
import 'create_category.dart';
import '../services/settings_controller.dart';
import 'preferences_page.dart';

class CampaignDashboardPage extends StatefulWidget {
  final String campaignName;
  final IconData campaignIcon;

  const CampaignDashboardPage({
    super.key,
    required this.campaignName,
    this.campaignIcon = Icons.shield,
  });

  @override
  State<CampaignDashboardPage> createState() => _CampaignDashboardPageState();
}

class _CampaignDashboardPageState extends State<CampaignDashboardPage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Mock de notas organizadas por categoría
  final Map<String, List<Map<String, dynamic>>> notesByCategory = {
    "Favoritos": [
      {
        "title": "Escudo Solar",
        "description": "Arma legendaria contra vampiros",
        "icon": Icons.star,
      }
    ],
    "Historia/Sesión": [
      {
        "title": "Sesión 1",
        "description": "Introducción a la aventura en Waterdeep",
        "icon": Icons.menu_book
      },
    ],
    "Personajes": [
      {
        "title": "Arthas",
        "description": "Paladín caído en desgracia que visitó el Castillo Ravenloft",
        "icon": Icons.person
      },
    ],
    "Ciudades": [
      {
        "title": "Waterdeep",
        "description": "Ciudad de los esplendores, punto de partida de la Sesión 1",
        "icon": Icons.location_city
      },
    ],
    "Lugares": [
      {
        "title": "Castillo Ravenloft",
        "description": "Fortaleza de Strahd mencionada por Arthas",
        "icon": Icons.castle
      },
    ],
    "Objetos": [
      {
        "title": "Amuleto de Ravenkind",
        "description": "Objeto mágico contra Strahd",
        "icon": Icons.shield
      },
    ],
    "Misiones": [
      {
        "title": "Derrotar a Strahd",
        "description": "Liberar Barovia de su tiranía",
        "icon": Icons.flag
      },
    ],
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    // Combinar todas las notas para búsqueda y navegación
    final allNotes = notesByCategory.values.expand((list) => list).toList();

    bool matches(Map<String, dynamic> n, String q) {
      if (q.isEmpty) return true;
      final title = (n["title"] as String).toLowerCase();
      if (settings.searchInDescription) {
        final desc = (n["description"] as String).toLowerCase();
        return title.contains(q) || desc.contains(q);
      }
      return title.contains(q);
    }

    final q = _searchQuery.toLowerCase();
    final filteredNotes = allNotes.where((n) => matches(n, q)).toList();
    final sortedFiltered = _sortList(filteredNotes, settings.sort);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: "Volver",
          onPressed: () => Navigator.pop(context),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Buscar notas...",
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              )
            : Row(
                children: [
                  Icon(widget.campaignIcon, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.campaignName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            tooltip: _isSearching ? "Cerrar búsqueda" : "Buscar Nota",
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = "";
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Preferencias",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PreferencesPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: "Crear Categoría",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateCategoryPage()),
              );
            },
          ),
        ],
      ),
      body: _isSearching
          ? _buildSearchResults(sortedFiltered, allNotes, context)
          : _buildCategories(allNotes, context, settings.sort),
      floatingActionButton: FloatingActionButton(
        tooltip: "Crear Nota",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateNotePage()),
          );
        },
        child: const Icon(Icons.note_add),
      ),
    );
  }

  // Orden alfabético según preferencia
  List<Map<String, dynamic>> _sortList(
    List<Map<String, dynamic>> list,
    SortOrder order,
  ) {
    final copy = [...list];
    copy.sort((a, b) {
      final at = (a["title"] as String);
      final bt = (b["title"] as String);
      final cmp = at.toLowerCase().compareTo(bt.toLowerCase());
      return order == SortOrder.titleAsc ? cmp : -cmp;
    });
    return copy;
  }

  // Vista con categorías, respetando orden de notas
  Widget _buildCategories(
    List<Map<String, dynamic>> allNotes,
    BuildContext context,
    SortOrder order,
  ) {
    final orderedCategories = [
      "Favoritos",
      ...notesByCategory.keys.where((c) => c != "Favoritos")
    ];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: orderedCategories.map((category) {
        final notes = _sortList(notesByCategory[category] ?? [], order);
        final isFavorites = category == "Favoritos";

        return ExpansionTile(
          leading: isFavorites ? const Icon(Icons.star, color: Colors.amber) : null,
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
                    builder: (_) => NoteDetailPage(
                      noteTitle: note["title"] as String,
                      noteDescription: note["description"] as String,
                      noteIcon: note["icon"] as IconData,
                      allNotes: allNotes,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  // Resultados de búsqueda, ordenados
  Widget _buildSearchResults(
    List<Map<String, dynamic>> notes,
    List<Map<String, dynamic>> allNotes,
    BuildContext context,
  ) {
    if (notes.isEmpty) {
      return const Center(child: Text("No se encontraron notas."));
    }
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (_, index) {
        final note = notes[index];
        return ListTile(
          leading: Icon(note["icon"] as IconData),
          title: Text(note["title"] as String),
          subtitle: Text(note["description"] as String),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NoteDetailPage(
                  noteTitle: note["title"] as String,
                  noteDescription: note["description"] as String,
                  noteIcon: note["icon"] as IconData,
                  allNotes: allNotes,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
