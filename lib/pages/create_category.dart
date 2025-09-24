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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Crear Categoría"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Nombre de la categoría
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nombre de la categoría",
                prefixIcon: Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 20),

            // Selección de icono
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
                  onTap: () {
                    setState(() {
                      _selectedIcon = icon;
                    });
                  },
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHigh,
                    child: Icon(
                      icon,
                      size: 28,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            // Botón de guardar
            ElevatedButton.icon(
              onPressed: () {
                // Guardar categoriaa
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
