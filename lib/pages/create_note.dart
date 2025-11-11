import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CreateNotePage extends StatefulWidget {
  const CreateNotePage({super.key});

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _customCategoryController = TextEditingController();

  String? _selectedCategory;

  final List<String> predefinedCategories = const [
    "Historia/Sesión",
    "Personajes",
    "Ciudades",
    "Lugares",
    "Objetos",
    "Misiones",
    "Personalizada",
  ];

  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _addImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source);
      if (picked != null) {
        setState(() => _images.add(File(picked.path)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se pudo obtener la imagen: $e")),
      );
    }
  }

  void _showImageSource() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Elegir de galería'),
              onTap: () {
                Navigator.pop(context);
                _addImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _addImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: "Volver",
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Crear Nota"),
        actions: [
          IconButton(
            tooltip: "Añadir imagen",
            icon: const Icon(Icons.add_a_photo),
            onPressed: _showImageSource,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Nombre de la nota",
                prefixIcon: Icon(Icons.edit_note),
              ),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Categoría",
                prefixIcon: Icon(Icons.category),
              ),
              value: _selectedCategory,
              items: predefinedCategories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),
            const SizedBox(height: 12),

            if (_selectedCategory == "Personalizada")
              TextField(
                controller: _customCategoryController,
                decoration: const InputDecoration(
                  labelText: "Nombre de categoría personalizada",
                  prefixIcon: Icon(Icons.add_circle),
                ),
              ),
            const SizedBox(height: 20),

            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: "Contenido",
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            const SizedBox(height: 20),

            // Botones rápidos también en el cuerpo
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _addImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo),
                    label: const Text("Galería"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _addImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Cámara"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_images.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _images
                    .map(
                      (file) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          file,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () {
                if ((_titleController.text).trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Agrega un título a la nota.")),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Nota creada (mock)")),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check),
              label: const Text("Guardar Nota"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                foregroundColor: scheme.onPrimary,
                backgroundColor: scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
