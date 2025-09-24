import 'package:flutter/material.dart';

class EditNotePage extends StatefulWidget {
  final String noteTitle;
  final String noteContent;
  final String noteCategory;

  const EditNotePage({
    super.key,
    required this.noteTitle,
    required this.noteContent,
    required this.noteCategory,
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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.noteTitle);
    _contentController = TextEditingController(text: widget.noteContent);

    // Si la categoría está en las predefinidas, la seleccionamos
    if (predefinedCategories.contains(widget.noteCategory)) {
      _selectedCategory = widget.noteCategory;
      _customCategoryController = TextEditingController();
    } else {
      // Si es personalizada, activamos esa opción
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
            const SizedBox(height: 40),

            // Boton de guardar cambios
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
