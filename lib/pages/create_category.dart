import 'package:flutter/material.dart';

class CreateCategoryPage extends StatefulWidget {
  const CreateCategoryPage({super.key});

  @override
  State<CreateCategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {
  final TextEditingController _nameController = TextEditingController();
  IconData? _selectedIcon;

  final List<IconData> availableIcons = [
    Icons.person,
    Icons.location_city,
    Icons.map,
    Icons.shield,
    Icons.book,
    Icons.explore,
    Icons.star,
    Icons.flag
  ];

  @override
  void dispose() {
    _nameController.dispose(); // ✅ liberar controlador
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: "Volver",
        ),
        title: const Text("Crear Categoría"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nombre de la categoría",
                prefixIcon: Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Selecciona un icono:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: availableIcons.map((icon) {
                final isSelected = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: isSelected
                        ? scheme.primaryContainer
                        : scheme.surfaceContainerHighest, // ✅ nombre correcto
                    child: Icon(
                      icon,
                      size: 28,
                      color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            ElevatedButton.icon(
              onPressed: () {
                // mock save
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Categoría creada (mock)")),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check),
              label: const Text("Guardar Categoría"),
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
