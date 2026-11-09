import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ALTERADO: necessário para o MethodChannel
import 'package:fl_chart/fl_chart.dart';
import 'package:refocus/controllers/apps_controller.dart'; // ALTERADO: para pegar nomes dos apps
import 'package:refocus/config/database.dart'; // NOVO: acesso ao banco (histórico)
import 'package:sqflite/sqflite.dart'; // NOVO

class ReportsScreen extends StatefulWidget {
  final AppsController? appsController; // ALTERADO

  const ReportsScreen(this.appsController, {Key? key}) : super(key: key); // ALTERADO

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedPeriod = 0; // 0 = Diário, 1 = Semanal, 2 = Mensal

  // ===== NOVO: dados reais =====
  static const MethodChannel _usageChannel = MethodChannel('com.refocus.app/usage');
  bool _isLoading = true;
  List<DateTime> _datas = []; // últimos 30 dias (o último é hoje)
  List<Map<String, int>> _usoPorDia = []; // packageName -> millis, um mapa por dia
  Map<String, String> _nomes = {}; // packageName -> nome do app

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final agora = DateTime.now();
      final hoje = DateTime(agora.year, agora.month, agora.day);
      final datas = List<DateTime>.generate(
        30,
            (i) => DateTime(hoje.year, hoje.month, hoje.day - (29 - i)),
      );

      // Nomes dos apps (também filtra apps de sistema)
      final Map<String, String> nomes = {};
      try {
        final dynamic instalados = await widget.appsController?.getInstalledApps();
        if (instalados is List) {
          for (final app in instalados) {
            final String? pkg = app.packageName;
            if (pkg != null) nomes[pkg] = (app.name as String?) ?? pkg;
          }
        }
      } catch (e) {
        debugPrint('Erro ao carregar apps instalados: $e');
      }

      // ALTERADO: hoje vem do Android; dias anteriores vêm do histórico salvo no banco
      final hojeUso = await _consultarHoje(nomes.keys.toSet());
      final db = await accessDatabase();
      await _salvarHoje(db, hoje, hojeUso);
      final historico = await _lerHistorico(db, datas.first);

      final List<Map<String, int>> usos = datas
          .map((dia) => dia == hoje
          ? hojeUso
          : (historico[_chave(dia)] ?? <String, int>{}))
          .toList();

      if (!mounted) return;
      setState(() {
        _datas = datas;
        _usoPorDia = usos;
        _nomes = nomes;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar relatórios: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  String _chave(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // Uso de HOJE: mesmo método que o Dashboard usa
  Future<Map<String, int>> _consultarHoje(Set<String> validos) async {
    final Map<String, int> resultado = {};
    try {
      final dynamic lista = await _usageChannel.invokeMethod('getUsageStats');
      if (lista is List) {
        for (final app in lista) {
          final String? pkg = app['packageName']?.toString();
          if (pkg == null) continue;
          if (validos.isNotEmpty && !validos.contains(pkg)) continue;
          final millis = (app['totalTime'] as num?)?.toInt() ?? 0;
          if (millis > 0) resultado[pkg] = (resultado[pkg] ?? 0) + millis;
        }
      }
    } catch (e) {
      debugPrint('Erro em getUsageStats: $e');
    }
    return resultado;
  }

  // Grava (ou atualiza) o uso de hoje no banco
  Future<void> _salvarHoje(Database db, DateTime hoje, Map<String, int> uso) async {
    final batch = db.batch();
    uso.forEach((pkg, ms) {
      batch.insert(
        'uso_diario',
        {'data': _chave(hoje), 'apps_package': pkg, 'tempo_total': ms},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit(noResult: true);
  }

  // Lê o histórico salvo: 'yyyy-MM-dd' -> (packageName -> millis)
  Future<Map<String, Map<String, int>>> _lerHistorico(Database db, DateTime desde) async {
    final rows = await db.query(
      'uso_diario',
      where: 'data >= ?',
      whereArgs: [_chave(desde)],
    );
    final Map<String, Map<String, int>> resultado = {};
    for (final r in rows) {
      final dia = r['data'].toString();
      final pkg = r['apps_package'].toString();
      final ms = (r['tempo_total'] as num?)?.toInt() ?? 0;
      resultado.putIfAbsent(dia, () => <String, int>{})[pkg] = ms;
    }
    return resultado;
  }

  int get _diasDoPeriodo => _selectedPeriod == 0 ? 1 : (_selectedPeriod == 1 ? 7 : 30);

  Map<String, int> _usoAgregado() {
    final Map<String, int> total = {};
    if (_usoPorDia.isEmpty) return total;
    for (final dia in _usoPorDia.sublist(_usoPorDia.length - _diasDoPeriodo)) {
      dia.forEach((pkg, ms) => total[pkg] = (total[pkg] ?? 0) + ms);
    }
    return total;
  }

  String _formatarTempo(int millis) {
    final totalMin = millis ~/ 60000;
    return '${totalMin ~/ 60}h${(totalMin % 60).toString().padLeft(2, '0')}';
  }

  String _data(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  // ===== FIM DO NOVO =====

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RELATÓRIOS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          // NOVO: botão para recarregar os dados
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarDados,
            tooltip: 'Atualizar Dados',
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              // Cabeçalho Principal
              const Text(
                'Tempo de Tela',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Seletor de Período (Botoes de Segmentação)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPeriodButton('DIÁRIO', 0),
                  _buildPeriodButton('SEMANAL', 1),
                  _buildPeriodButton('MENSAL', 2),
                ],
              ),
              const SizedBox(height: 24),

              // Card de Dados de Uso
              _buildUsageStatsCard(),

              const SizedBox(height: 24),

              // Card com Gráfico
              _buildChartCard(),

              const SizedBox(height: 24),

              // Lista de Apps no período
              _buildAppListCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, int index) {
    final isSelected = _selectedPeriod == index;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedPeriod = index;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.black : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: isSelected ? 4 : 1,
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildUsageStatsCard() {
    String totalStr = '';
    String subStr = '';

    // ALTERADO: valores reais no lugar dos textos fixos
    if (_isLoading || _datas.isEmpty) {
      totalStr = '...';
      subStr = 'Carregando...';
    } else {
      final hoje = _datas.last;
      totalStr = _formatarTempo(
          _usoAgregado().values.fold(0, (soma, ms) => soma + ms));

      if (_selectedPeriod == 0) {
        subStr = 'Data: ${_data(hoje)}';
      } else if (_selectedPeriod == 1) {
        subStr = 'Semana: ${_data(_datas[_datas.length - 7])} - ${_data(hoje)}';
      } else {
        subStr = 'Mês: ${_data(_datas.first)} - ${_data(hoje)}';
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              subStr,
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Total de tempo gasto:',
              style: TextStyle(color: Colors.black38, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              totalStr,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[900],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    final spots = _getChartSpots(); // ALTERADO: calcula o limite dos eixos
    final double maxY =
        spots.map((s) => s.y).fold(0.0, (a, b) => a > b ? a : b) * 1.2;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Histórico de Uso',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (spots.length - 1).toDouble(), // ALTERADO
                  minY: 0,
                  maxY: maxY < 1 ? 1 : maxY, // ALTERADO
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blueGrey,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blueGrey.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ALTERADO: pontos reais (horas de uso por dia)
  // Diário e Semanal: últimos 7 dias | Mensal: últimos 30 dias
  List<FlSpot> _getChartSpots() {
    if (_usoPorDia.isEmpty) {
      return const [FlSpot(0, 0), FlSpot(1, 0)];
    }

    final int qtd = _selectedPeriod == 2 ? 30 : 7;
    final inicio = _usoPorDia.length - qtd;

    return List<FlSpot>.generate(qtd, (i) {
      final millis = _usoPorDia[inicio + i].values.fold(0, (soma, ms) => soma + ms);
      return FlSpot(i.toDouble(), millis / 3600000.0);
    });
  }

  Widget _buildAppListCard() {
    // ALTERADO: lista real, ordenada do app mais usado para o menos usado
    final ordenados = _usoAgregado().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final List<Map<String, String>> appsData = ordenados
        .take(10)
        .map((e) => {
      'name': _nomes[e.key] ?? e.key,
      'time': _formatarTempo(e.value),
    })
        .toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Uso por aplicativo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...appsData.map((app) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    app['name']!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    app['time']!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}