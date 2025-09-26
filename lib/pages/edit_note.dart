import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditNotePage extends StatefulWidget {
  final String noteTitle;
  final String noteContent;
  final String noteCategory;
  final List<String> noteImages; // 👈 rutas de imágenes existentes

  const EditNotePage({
    super.key,
    required this.noteTitle,
    required this.noteContent,
    required this.noteCategory,
    this.noteImages = const [], // por defecto vacío
  });

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _customCategoryController;

  String? _selectedCategory;

  final List<String> predefinedCategories = [
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

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _images.add(File(picked.path));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.noteTitle);
    _contentController = TextEditingController(text: widget.noteContent);

    // Cargar imágenes iniciales (convertimos String -> File si existen rutas)
    for (final path in widget.noteImages) {
      _images.add(File(path));
    }

    if (predefinedCategories.contains(widget.noteCategory)) {
      _selectedCategory = widget.noteCategory;
      _customCategoryController = TextEditingController();
    } else {
      _selectedCategory = "Personalizada";
      _customCategoryController =
          TextEditingController(text: widget.noteCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Editar Nota"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Nombre de la nota
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Nombre de la nota",
                prefixIcon: Icon(Icons.edit_note),
              ),
            ),
            const SizedBox(height: 20),

            // Categoría
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Categoría",
                prefixIcon: Icon(Icons.category),
              ),
              value: _selectedCategory,
              items: predefinedCategories
                  .map((cat) =>
                      DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 12),

            // Campo para categoría personalizada
            if (_selectedCategory == "Personalizada")
              TextField(
                controller: _customCategoryController,
                decoration: const InputDecoration(
                  labelText: "Nombre de categoría personalizada",
                  prefixIcon: Icon(Icons.add_circle),
                ),
              ),
            const SizedBox(height: 20),

            // Contenido de la nota
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

            // Botón para añadir imagen
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Añadir Imagen"),
            ),
            const SizedBox(height: 12),

            // Vista previa de imágenes
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
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 40),

            // Botón de guardar cambios
            ElevatedButton.icon(
              onPressed: () {
                // Aquí luego guardaremos los cambios
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cambios guardados (mock)")),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.save),
              label: const Text("Guardar cambios"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
