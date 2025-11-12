import 'package:flutter/material.dart';
import '../data/repositories/campaign_repo.dart';

class CreateCampaignPage extends StatefulWidget {
  const CreateCampaignPage({super.key});

  @override
  State<CreateCampaignPage> createState() => _CreateCampaignPageState();
}

class _CreateCampaignPageState extends State<CreateCampaignPage> {
  final _name = TextEditingController();
  String? _edition;
  IconData? _icon;

  final _repo = CampaignRepo();

  final List<String> editions = const ["Dungeons & Dragons 5e", "Pathfinder", "Call of Cthulhu"];
  final List<IconData> icons = const [Icons.shield, Icons.map, Icons.castle, Icons.explore];

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text("Crear Campaña"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: "Nombre", prefixIcon: Icon(Icons.edit)),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _edition,
            items: editions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _edition = v),
            decoration: const InputDecoration(labelText: "Edición", prefixIcon: Icon(Icons.book)),
          ),
          const SizedBox(height: 16),
          const Text("Selecciona un icono:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: icons.map((ic) {
              final selected = _icon == ic;
              return GestureDetector(
                onTap: () => setState(() => _icon = ic),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: selected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(ic, color: selected ? Theme.of(context).colorScheme.primary : null),
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
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ingresa un nombre")));
                return;
              }
              await _repo.insertCampaign(
                name: name,
                edition: _edition,
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
