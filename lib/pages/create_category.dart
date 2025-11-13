import 'package:flutter/material.dart';
import '../data/repositories/category_repo.dart';

class CreateCategoryPage extends StatefulWidget {
  final int campaignId;

  const CreateCategoryPage({
    super.key,
    required this.campaignId,
  });

  @override
  State<CreateCategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {
  final _name = TextEditingController();
  final _repo = CategoryRepo();

  IconData? _icon;

  final List<IconData> _icons = const [
    Icons.category,
    Icons.bookmark,
    Icons.shield,
    Icons.map,
    Icons.casino,
    Icons.auto_stories,
  ];

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Crear Categoría"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: "Nombre de la categoría",
              prefixIcon: Icon(Icons.edit),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Selecciona un icono:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _icons.map((ic) {
              final selected = _icon == ic;
              return GestureDetector(
                onTap: () => setState(() => _icon = ic),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: selected
                      ? scheme.primaryContainer
                      : scheme.surfaceContainerHighest,
                  child: Icon(
                    ic,
                    color: selected ? scheme.primary : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.check),
            label: const Text("Guardar"),
            onPressed: () async {
              final name = _name.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Ingresa un nombre")),
                );
                return;
              }

              await _repo.insertCustomCategory(
                campaignId: widget.campaignId,
                name: name,
                iconCodePoint: _icon?.codePoint,
              );

              if (!mounted) return;
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );
  }
}
