import 'package:flutter/material';

class ManageAppsScreen extends StatefulWidget {
  const ManageAppsScreen({Key? key}) : super(key: key);

  @override
  State<ManageAppsScreen> createState() => _ManageAppsScreenState();
}

class _ManageAppsScreenState extends State<ManageAppsScreen> {
  // Lista de simulação de apps monitorados
  final List<Map<String, dynamic>> _apps = [
    {
      'name': 'Instagram',
      'used': '1h30',
      'limit': '1h30',
      'status': 'Bloqueado (limite de tempo atingido)',
      'isBlocked': true,
      'isExpanded': false,
    },
    {
      'name': 'TikTok',
      'used': '0h47',
      'limit': '1h00',
      'status': 'Ativo',
      'isBlocked': false,
      'isExpanded': false,
    },
    {
      'name': 'YouTube',
      'used': '0h00',
      'limit': '0h30',
      'status': 'Ativo',
      'isBlocked': false,
      'isExpanded': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GERENCIAR APPS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Apps monitorados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _apps.length,
                itemBuilder: (context, index) {
                  final app = _apps[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    child: ExpansionTile(
                      key: ValueKey(app['name']),
                      title: Text(
                        "${app['name']} | ${app['used']}/${app['limit']}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: app['isBlocked'] ? Colors.red[800] : Colors.black87,
                        ),
                      ),
                      initiallyExpanded: app['isExpanded'],
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Limite: ${app['limit']} por dia",
                                style: const TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Status: ${app['status']}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: app['isBlocked'] ? Colors.red : Colors.green,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      // Logica para editar limite
                                    },
                                    child: const Text('Editar Limite'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Logica para remover monitoramento
                                    },
                                    child: const Text('Remover', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Abre o fluxo para adicionar novos apps da lista do sistema
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Adicionar App',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
