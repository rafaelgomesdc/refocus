import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:refocus/controllers/monitoramento_controller.dart';
import 'screens/dashboard_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/manage_apps_screen.dart';

import 'package:refocus/controllers/apps_controller.dart';
import 'package:refocus/config/database.dart';

import 'package:refocus/config/permission.dart';

const MethodChannel usageChannel = MethodChannel('com.refocus.app/usage');

Future<void> listarApps(AppsController appsController) async {
  final apps = await appsController.getInstalledApps();

  for (final app in apps) {
    print("==========APPS==========");
    print("App name: " + app.name!);
    print("Package name: " + app.packageName!);
    print("========================");
  }
  final monitoredApps = await appsController.getMonitoredApps();

  print("CARREGAR APPS MONITORADOS");
  for (final app in monitoredApps) {
    print("=====APPS MONITORADOS=====");
    print(app);
    print("==========================");
  }
  print("FIM - CARREGAR APPS MONITORADOS");
}

/*FUNCAO PARA TESTE DE MONITORAMENTO*/
Future<void> startMonitoring() async {
  await usageChannel.invokeMethod('startMonitoring',);
}
/*FIM - FUNCAO TESTE*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //Inicializa o flutter para depois chamar MethodChannel
  final appsController = AppsController(await accessDatabase());
  final monitoramentoController = MonitoramentoController();

  //await listarApps(appsController);

  /*TESTE DE MONITORAMENTO*/
  await startMonitoring();
  /*FIM - TESTE*/

  final permissions = await checkPermissions();
  print("=====PERMISSÃO DE DADOS DE USO=====");
  print(permissions);
  print("===FIM PERMISSÃO DE DADOS DE USO===");

  await appsController.getInstalledApps();

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
