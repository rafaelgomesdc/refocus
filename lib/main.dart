import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/manage_apps_screen.dart';

import 'package:refocus/controllers/apps_controller.dart';
import 'package:refocus/config/database.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //Inicializa o flutter para depois chamar MethodChannel
  final appsController = AppsController(await accessDatabase());

  await listarApps(appsController);

  runApp(ReFocusApp(appsController));
}

class ReFocusApp extends StatelessWidget {
  final AppsController appsController;

  ReFocusApp(AppsController this.appsController, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReFocus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: MainNavigationShell(appsController),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final AppsController? appsController;

  MainNavigationShell(AppsController this.appsController, {Key? key}) : super(key: key);

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
      ManageAppsScreen(widget.appsController),
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
