import 'package:flutter/material.dart';
import '../providers/agent_versement_provider.dart';
import '../../../../shared/models/versement_model.dart';

class AgentVersementsScreen extends StatelessWidget {
  const AgentVersementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Versements'),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<VersementModel>>(
        future: AgentVersementProvider().fetchVersements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          final versements = snapshot.data ?? [];
          return ListView.separated(
            itemCount: versements.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final v = versements[index];
              return ListTile(
                title: Text('Versement #${v.id}'),
                subtitle: Text('Montant: ${v.amount}\nDate: ${v.date}'),
                onTap: () async {
                  final detail = await AgentVersementProvider().fetchVersementDetail(v.id);
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Détails du versement #${v.id}'),
                      content: Text('Montant: ${detail.amount}\nDate: ${detail.date}\nInfo: ${detail.info}'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fermer')),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
