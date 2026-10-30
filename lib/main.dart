import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:refocus/controllers/monitoramento_controller.dart';
import 'screens/dashboard_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/manage_apps_screen.dart';

import 'package:refocus/controllers/apps_controller.dart';
import 'package:refocus/config/database.dart';

import 'package:refocus/config/permission.dart';

const MethodChannel usageChannel = MethodChannel('com.refocus.app/usage'); // MethodChannel para dados de uso

Future<void> startMonitoring() async {
  // Chama o inicio do monitoramento nativo via MethodChannel
  await usageChannel.invokeMethod('startMonitoring',);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Inicializa o flutter para depois chamar MethodChannel

  final appsController = AppsController(await accessDatabase());
  final monitoramentoController = MonitoramentoController();

  await startMonitoring(); // Inicia o monitoramento

  final permissions = await checkPermissions(); // Chama a verificacao de permissoes necessarias

  /* DEPURACAO */
  print("=====PERMISSÃO DE DADOS DE USO=====");
  print(permissions);
  print("===FIM PERMISSÃO DE DADOS DE USO===");
  /* FIM - DEPURACAO */

  await appsController.getInstalledApps(); // Atualiza os aplicativos instalados no banco de dados

  runApp(ReFocusApp(appsController, monitoramentoController));
}

class ReFocusApp extends StatelessWidget {
  final AppsController appsController;
  final MonitoramentoController monitoramentoController;

  ReFocusApp(AppsController this.appsController, this.monitoramentoController, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReFocus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: MainNavigationShell(appsController, monitoramentoController),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final AppsController? appsController;
  final MonitoramentoController? monitoramentoController;

  MainNavigationShell(AppsController this.appsController, this.monitoramentoController, {Key? key}) : super(key: key);

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 1; // Inicia na aba Home (Dashboard)

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      const ReportsScreen(),
      const DashboardScreen(),
      ManageAppsScreen(widget.appsController, widget.monitoramentoController),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.blueGrey[800],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Relatórios',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_on),
              label: 'Gerenciar',
            ),
          ],
        ),
      ),
    );
  }
}
