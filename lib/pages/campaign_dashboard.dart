import 'package:flutter/material.dart';
import '../data/repositories/category_repo.dart';
import '../data/repositories/note_repo.dart';
import '../models/category.dart';
import '../models/note.dart';
import 'create_note.dart';
import 'create_category.dart';
import 'note_detail.dart';
import 'preferences_page.dart';

class CampaignDashboardPage extends StatefulWidget {
  final int campaignId;
  final String campaignName;
  final IconData campaignIcon;

  const CampaignDashboardPage({
    super.key,
    required this.campaignId,
    required this.campaignName,
    this.campaignIcon = Icons.shield,
  });

  @override
  State<CampaignDashboardPage> createState() => _CampaignDashboardPageState();
}

class _CampaignDashboardPageState extends State<CampaignDashboardPage> {
  final _catRepo = CategoryRepo();
  final _noteRepo = NoteRepo();

  late Future<List<Category>> _futureCats;
  late Future<List<Note>> _futureAllNotes;

  bool _isSearching = false;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _futureCats = _catRepo.getByCampaign(widget.campaignId);
    _futureAllNotes = _noteRepo.getNotesByCampaign(widget.campaignId);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Buscar notas...",
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
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
            onPressed: () {
              setState(() {
                if (_isSearching) _searchCtrl.clear();
                _isSearching = !_isSearching;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Preferencias",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PreferencesPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: "Crear Categoría",
            onPressed: () async {
              final created = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CreateCategoryPage(campaignId: widget.campaignId),
                ),
              );
              if (created == true) setState(_reload);
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([_futureCats, _futureAllNotes]),
        builder: (context, AsyncSnapshot<List<dynamic>> snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final categories = (snap.data?[0] as List<Category>?) ?? [];
          final allNotes = (snap.data?[1] as List<Note>?) ?? [];

          final favorites = allNotes.where((n) => n.favorite).toList();

          final q = _searchCtrl.text.trim().toLowerCase();
          List<Note> applySearch(List<Note> list) {
            if (q.isEmpty) return list;
            return list.where((n) {
              return n.title.toLowerCase().contains(q);
              // o también descripción:
              // return n.title.toLowerCase().contains(q) ||
              //        n.description.toLowerCase().contains(q);
            }).toList();
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              ExpansionTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: const Text(
                  "Favoritos",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                children: applySearch(favorites)
                    .map((n) => _noteTile(context, n, allNotes))
                    .toList(),
              ),
              for (final cat in categories)
                ExpansionTile(
                  title: Text(
                    cat.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  leading: cat.iconCodePoint != null
                      ? Icon(
                          IconData(
                            cat.iconCodePoint!,
                            fontFamily: 'MaterialIcons',
                          ),
                        )
                      : null,
                  children: applySearch(
                    allNotes.where((n) => n.categoryId == cat.id).toList(),
                  ).map((n) => _noteTile(context, n, allNotes)).toList(),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Crear Nota",
        child: const Icon(Icons.note_add),
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => CreateNotePage(
                campaignId: widget.campaignId,
                categoriesFuture: _catRepo.getByCampaign(widget.campaignId),
              ),
            ),
          );
          if (created == true) setState(_reload);
        },
      ),
    );
  }

  Widget _noteTile(BuildContext context, Note n, List<Note> all) {
    return ListTile(
      leading: const Icon(Icons.notes),
      title: Text(n.title),
      subtitle: Text(
        n.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        tooltip:
            n.favorite ? "Quitar de favoritos" : "Añadir a favoritos",
        icon: Icon(
          n.favorite ? Icons.star : Icons.star_border,
          color: n.favorite ? Colors.amber : null,
        ),
        onPressed: () async {
          final newValue = !n.favorite;
          if (n.id > 0) {
            await _noteRepo.toggleFavorite(n.id, newValue);
            if (!mounted) return;
            setState(_reload); // recarga notas para reflejar cambio
          }
        },
      ),
      onTap: () async {
        final List<Map<String, dynamic>> allNotesMap = all
            .map(
              (x) => {
                'id': x.id,
                'categoryId': x.categoryId,
                'title': x.title,
                'description': x.description,
                'icon': Icons.notes,
                'images': x.images,
                'favorite': x.favorite,
              },
            )
            .toList();

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NoteDetailPage(
              noteId: n.id,
              campaignId: widget.campaignId,
              categoryId: n.categoryId,
              noteTitle: n.title,
              noteDescription: n.description,
              noteIcon: Icons.notes,
              imagePaths: n.images,
              allNotes: allNotesMap,
              initialFavorite: n.favorite,
            ),
          ),
        );

        setState(_reload);
      },
    );
  }
}
