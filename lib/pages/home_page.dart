import 'package:flutter/material.dart';
import '../data/repositories/campaign_repo.dart';
import '../models/campaign.dart';
import 'campaign_dashboard.dart';
import 'create_campaign.dart';

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
    setState(() => _future = _repo.getAll());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Campañas"), centerTitle: true),
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
                return Card(
                  child: ListTile(
                    leading: Icon(
                      IconData(c.iconCodePoint ?? Icons.shield.codePoint, fontFamily: 'MaterialIcons'),
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Creada: ${DateTime.fromMillisecondsSinceEpoch(c.createdAt)}"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CampaignDashboardPage(
                            campaignId: c.id,
                            campaignName: c.name,
                            campaignIcon: IconData(c.iconCodePoint ?? Icons.shield.codePoint, fontFamily: 'MaterialIcons'),
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
          if (created == true) _refresh();
        },
      ),
    );
  }
}
