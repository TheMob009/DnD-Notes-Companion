import 'package:flutter/material.dart';
import '../data/repositories/category_repo.dart';

class CreateCategoryPage extends StatefulWidget {
  final int campaignId;
  const CreateCategoryPage({super.key, required this.campaignId});

  @override
  State<CreateCategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {
  final _name = TextEditingController();
  IconData? _icon;
  final _repo = CategoryRepo();

  final icons = const [
    Icons.person, Icons.location_city, Icons.map, Icons.shield, Icons.book, Icons.explore, Icons.star, Icons.flag
  ];

  @override
  void dispose() { _name.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(), title: const Text("Crear Categoría")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: "Nombre", prefixIcon: Icon(Icons.edit)),
          ),
          const SizedBox(height: 16),
          const Text("Icono:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12, runSpacing: 12,
            children: icons.map((ic) {
              final sel = _icon == ic;
              return GestureDetector(
                onTap: () => setState(() => _icon = ic),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: sel ? Theme.of(context).colorScheme.primaryContainer : null,
                  child: Icon(ic, color: sel ? Theme.of(context).colorScheme.primary : null),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.check),
            label: const Text("Guardar Categoría"),
            onPressed: () async {
              final name = _name.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ingresa un nombre")));
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
