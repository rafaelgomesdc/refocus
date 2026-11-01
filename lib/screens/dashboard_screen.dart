import 'package:flutter/material.dart';

/*TESTE DE MONITORAMENTO*/
import 'package:flutter/services.dart';
import 'package:refocus/controllers/apps_controller.dart';
import 'package:refocus/controllers/monitoramento_controller.dart';
import 'package:refocus/objs/app_monitorado.dart';
import 'package:refocus/utils/timeFormat.dart';

class DashboardScreen extends StatefulWidget {
  final AppsController? appsController;
  final MonitoramentoController? monitoramentoController;

  DashboardScreen(this.appsController, this.monitoramentoController, {Key? key})
      : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}


class _DashboardScreenState extends State<DashboardScreen> {

  List<AppMonitorado> _appsMonitorados = [];
  Map<dynamic, dynamic> _dadosUso = {};

  List<Map<String,dynamic>> _apps = [];

  static const MethodChannel usageChannel =  MethodChannel('com.refocus.app/usage');

  @override
  void initState() {
    super.initState();
    getMonitoredApps();
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
          'limit': timeFormat(app.tempoLimite!),
          'status': 'Ativo',
          'isBlocked': false,
          'isExpanded': false,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'REFOCUS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seção Hoje
            Container(
              color: Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hoje',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tempo de Tela',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '2h27',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.grey),
            // Principais Apps
            Padding(
              padding: const EdgeInsets.all(16.0),
              key: const ValueKey('principais_apps'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Principais Apps',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (var app in _apps)
                    _buildAppUsageRow(app['name'], app['used'], Icons.apps),
                  /*_buildAppUsageRow('Instagram', '0h33', Icons.camera_alt),
                  _buildAppUsageRow('TikTok', '0h29', Icons.music_note),
                  _buildAppUsageRow('Whatsapp', '0h24', Icons.chat),*/
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppUsageRow(String appName, String duration, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.blueGrey[700]),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              appName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            duration,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
