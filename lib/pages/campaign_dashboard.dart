import 'package:flutter/material.dart';
import 'create_category.dart';
import 'create_note.dart';
import 'note_detail.dart';

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
  Widget build(BuildContext context) {
    // Todas las notas combinadas en una sola lista (necesario para links en NoteDetailPage)
    final allNotes = notesByCategory.values.expand((list) => list).toList();

    // Filtrar por título
    final filteredNotes = _searchQuery.isEmpty
        ? allNotes
        : allNotes
            .where((note) => (note["title"] as String)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
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
      body: _isSearching
          ? _buildSearchResults(filteredNotes, allNotes, context)
          : _buildCategories(allNotes, context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateNotePage(),
            ),
          );
        },
        tooltip: "Crear Nota",
        child: const Icon(Icons.note_add),
      ),
    );
  }

  // Vista normal con categorías
  Widget _buildCategories(
      List<Map<String, dynamic>> allNotes, BuildContext context) {
    final orderedCategories = ["Favoritos", ...notesByCategory.keys.where((c) => c != "Favoritos")];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: orderedCategories.map((category) {
        final notes = notesByCategory[category] ?? [];
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
                    builder: (context) => NoteDetailPage(
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

  // Vista de resultados de búsqueda
  Widget _buildSearchResults(
      List<Map<String, dynamic>> notes,
      List<Map<String, dynamic>> allNotes,
      BuildContext context) {
    if (notes.isEmpty) {
      return const Center(child: Text("No se encontraron notas."));
    }
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
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
