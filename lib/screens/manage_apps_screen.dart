import 'package:flutter/material.dart';
import 'package:refocus/controllers/apps_controller.dart';
import 'package:refocus/controllers/monitoramento_controller.dart';
import 'package:refocus/objs/app_monitorado.dart';
import 'package:refocus/utils/timeFormat.dart';

class ManageAppsScreen extends StatefulWidget {
  final AppsController? appsController;
  final MonitoramentoController? monitoramentoController;

  ManageAppsScreen(this.appsController, this.monitoramentoController, {Key? key}) : super(key: key);

  @override
  State<ManageAppsScreen> createState() => _ManageAppsScreenState();
}

class _ManageAppsScreenState extends State<ManageAppsScreen> {
  List? _appsInstalados = [];
  List<AppMonitorado> _appsMonitorados = []; //widget.appsController!.getMonitoredApps();
  Map<dynamic, dynamic> _dadosUso = {};

  // Lista de simulação de apps monitorados
  List<Map<String, dynamic>> _apps = [];

  @override
  void initState() {
    super.initState();
    getMonitoredApps();
  }


  /*final List<Map<String, dynamic>> _apps = [
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
  ];*/

  Future<void> getInstalledApps() async {
    this._appsInstalados = await widget.appsController!.consultInstalledApps();
  }

  Future<void> getMonitoredApps() async {
    final appsMonitorados = await widget.appsController!.getMonitoredApps();
    final dadosUso = await widget.monitoramentoController!.consultarUsoHoje(appsMonitorados);

    setState(() {
      _appsMonitorados = appsMonitorados;
      _dadosUso = dadosUso;

      _apps.clear();

      for (var app in _appsMonitorados) {
        _apps.add({
          'name': app.name,
          'package': app.packageName,
          'used': timeFormat(_dadosUso[app.packageName] ?? 0),
          'limit': app.tempoLimite,
          'status': 'Ativo',
          'isBlocked': false,
          'isExpanded': false,
        });
      }
    });
  }

  void _showTimeLimitDialog(
      String appName,
      String packageName,
      ) {
    final TextEditingController timeController =
    TextEditingController();

    //Tela de configuração de app monitorado
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Configurar aplicativo',
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                packageName,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: timeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tempo limite',
                  hintText: 'Ex: 60',
                  suffixText: 'minutos',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),

            ElevatedButton(
              onPressed: () async {
                //Lógica para registrar no banco de dados
                if (timeController.text.isEmpty) {
                  return;
                }

                await widget.appsController!.storeMonitoredApp(packageName, int.parse(timeController.text));

                await getMonitoredApps();

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAppSelection() async {
    await getInstalledApps();

    //Tela selecao de aplicativos
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Selecionar aplicativo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: _appsInstalados!.length,
                  itemBuilder: (context, index) {
                    final app = _appsInstalados![index];

                    final String appName = app.name;
                    final String packageName = app.packageName;

                    return ListTile(
                      leading: const Icon(Icons.apps),
                      title: Text(appName),
                      subtitle: Text(packageName),

                      // Quando clicar no aplicativo
                      onTap: () {
                        Navigator.pop(context);

                        _showTimeLimitDialog(
                          appName,
                          packageName,
                        );
                      },
                    );
                  },
                ),
              ),
              /*
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: widget.monitoramentoController.consultarUsoHoje(),
                  child: const Text('Atualizar uso'),
                ),
              )*/
            ],
          ),
        );
      },
    );
  }

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
                                    onPressed: () async {
                                      // Logica para remover monitoramento
                                      await widget.appsController!.removeMonitoredApp(app['package']);
                                      await getMonitoredApps();
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
                _showAppSelection();
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
