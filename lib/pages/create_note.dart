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
  final TextEditingController _customCategoryController =
      TextEditingController();

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Crear Nota"),
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

            // Boton Guardar
            ElevatedButton.icon(
              onPressed: () {
                // Guardar la nota luego
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Nota creada (mock)")),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check),
              label: const Text("Guardar Nota"),
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
