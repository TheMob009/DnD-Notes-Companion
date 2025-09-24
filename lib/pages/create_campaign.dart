import 'package:flutter/material.dart';

class CreateCampaignPage extends StatefulWidget {
  const CreateCampaignPage({super.key});

  @override
  State<CreateCampaignPage> createState() => _CreateCampaignPageState();
}

class _CreateCampaignPageState extends State<CreateCampaignPage> {
  final TextEditingController _nameController = TextEditingController();

  String? _selectedEdition;
  IconData? _selectedIcon;

  final List<String> editions = [
    "Dungeons & Dragons 5e",
    "Pathfinder",
    "Call of Cthulhu",
  ];

  final List<IconData> campaignIcons = [
    Icons.shield,
    Icons.map,
    Icons.castle,
    Icons.explore
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Crear Campaña"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Nombre de campaña
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nombre de la campaña",
                prefixIcon: Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 20),

            // Dropdown de edición
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Edición",
                prefixIcon: Icon(Icons.book),
              ),
              value: _selectedEdition,
              items: editions
                  .map((edition) =>
                      DropdownMenuItem(value: edition, child: Text(edition)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedEdition = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Selección de icono
            const Text(
              "Selecciona un icono para la campaña:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: campaignIcons.map((icon) {
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
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
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
                // Aquí luego guardaremos la campaña
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Campaña creada (mock)")),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check),
              label: const Text("Guardar"),
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
