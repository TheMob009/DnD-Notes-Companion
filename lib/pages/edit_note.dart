import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/repositories/note_repo.dart';
import '../data/repositories/category_repo.dart';
import '../models/category.dart';
import '../models/note.dart';

class EditNotePage extends StatefulWidget {
  final Note note;
  const EditNotePage({super.key, required this.note});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  final _picker = ImagePicker();
  final _noteRepo = NoteRepo();
  final _catRepo = CategoryRepo();

  int? _selectedCategoryId;
  late List<File> _images;

  @override
  void initState() {
    super.initState();
    _title.text = widget.note.title;
    _content.text = widget.note.description;
    _selectedCategoryId = widget.note.categoryId;
    _images = widget.note.images.map((p) => File(p)).toList();
  }

  Future<void> _addImage(ImageSource src) async {
    final picked = await _picker.pickImage(source: src);
    if (picked != null) setState(() => _images.add(File(picked.path)));
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text("Editar Nota"),
        actions: [
          IconButton(
            tooltip: "Añadir imagen",
            icon: const Icon(Icons.add_a_photo),
            onPressed: _showImageSource,
          ),
        ],
      ),
      body: FutureBuilder<List<Category>>(
        future: _catRepo.getByCampaign(widget.note.campaignId),
        builder: (context, snap) {
          final categories = snap.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _title,
                decoration: const InputDecoration(
                    labelText: "Nombre de la nota", prefixIcon: Icon(Icons.edit_note)),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(labelText: "Categoría", prefixIcon: Icon(Icons.category)),
                items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _content,
                maxLines: 8,
                decoration: const InputDecoration(
                    labelText: "Contenido", alignLabelWithHint: true, prefixIcon: Icon(Icons.notes)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: OutlinedButton.icon(
                          onPressed: () => _addImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo),
                          label: const Text("Galería"))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: OutlinedButton.icon(
                          onPressed: () => _addImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text("Cámara"))),
                ],
              ),
              const SizedBox(height: 12),
              if (_images.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _images
                      .map((f) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(f, width: 120, height: 120, fit: BoxFit.cover),
                          ))
                      .toList(),
                ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Guardar cambios"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                ),
                onPressed: () async {
                  final updated = widget.note.copyWith(
                    title: _title.text.trim(),
                    description: _content.text.trim(),
                    categoryId: _selectedCategoryId,
                  );
                  await _noteRepo.updateNote(updated);
                  await _noteRepo.replaceImages(updated.id, _images.map((e) => e.path).toList());
                  if (!mounted) return;
                  Navigator.pop(context, true);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showImageSource() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Elegir de galería'),
                onTap: () {
                  Navigator.pop(context);
                  _addImage(ImageSource.gallery);
                }),
            ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _addImage(ImageSource.camera);
                }),
          ],
        ),
      ),
    );
  }
}
