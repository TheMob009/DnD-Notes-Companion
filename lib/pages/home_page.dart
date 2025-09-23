import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final campaigns = [
      {"name": "La Maldición de Strahd", "date": "12/03/2024"},
      {"name": "Reinos Olvidados", "date": "05/05/2024"},
      {"name": "Mazmorras Caseras", "date": "20/07/2024"},
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
              title: Text(
                campaign["name"]!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Creada el ${campaign["date"]}"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                // Aquí irá navegación al dashboard
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Aquí irá crear nueva campaña
        },
        icon: const Icon(Icons.add),
        label: const Text("Nueva Campaña"),
      ),
    );
  }
}
