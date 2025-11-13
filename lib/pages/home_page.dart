import 'package:flutter/material.dart';
import '../data/repositories/campaign_repo.dart';
import '../models/campaign.dart';
import 'campaign_dashboard.dart';
import 'create_campaign.dart';
import 'preferences_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _repo = CampaignRepo();
  late Future<List<Campaign>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.getAll();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _repo.getAll();
    });
  }

  Future<void> _confirmDeleteCampaign(Campaign c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar campaña"),
        content: Text(
          'Se eliminará la campaña "${c.name}" y todo su contenido (categorías y notas asociadas). '
          '¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _repo.deleteCampaign(c.id); // debe borrar la campaña (y su contenido)
      if (!mounted) return;
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Campaña "${c.name}" eliminada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campañas"),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: "Preferencias",
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PreferencesPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Campaign>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final campaigns = snap.data ?? [];
          if (campaigns.isEmpty) {
            return const Center(child: Text("Aún no hay campañas"));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: campaigns.length,
              itemBuilder: (_, i) {
                final c = campaigns[i];
                final icon = IconData(
                  c.iconCodePoint ?? Icons.shield.codePoint,
                  fontFamily: 'MaterialIcons',
                );
                return Card(
                  child: ListTile(
                    leading: Icon(
                      icon,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      c.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Creada: ${DateTime.fromMillisecondsSinceEpoch(c.createdAt)}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: "Eliminar campaña",
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmDeleteCampaign(c),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 18),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CampaignDashboardPage(
                            campaignId: c.id,
                            campaignName: c.name,
                            campaignIcon: icon,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Crear Campaña",
        child: const Icon(Icons.add),
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CreateCampaignPage()),
          );
          if (created == true) {
            _refresh();
          }
        },
      ),
    );
  }
}
