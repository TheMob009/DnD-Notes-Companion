import 'package:flutter/material.dart';
import 'campaign_dashboard.dart';
import 'create_campaign.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final campaigns = [
      {"name": "La Maldición de Strahd", "date": "12/03/2024", "icon": Icons.shield},
      {"name": "Reinos Olvidados", "date": "05/05/2024", "icon": Icons.map},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Campañas"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: campaigns.length,
        itemBuilder: (context, index) {
          final campaign = campaigns[index];
          return Card(
            child: ListTile(
              leading: Icon(
                campaign["icon"] as IconData,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                campaign["name"]! as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Creada el ${campaign["date"]}"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CampaignDashboardPage(
                      campaignName: campaign["name"]! as String,
                      campaignIcon: campaign["icon"] as IconData,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateCampaignPage(),
              ),
            );
          },
          tooltip: "Crear Campaña",
          child: const Icon(Icons.add),
      )
    );
  }
}
