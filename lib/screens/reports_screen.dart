import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedPeriod = 0; // 0 = Diário, 1 = Semanal, 2 = Mensal

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

    if (_selectedPeriod == 0) {
      totalStr = '4h37';
      subStr = 'Data: 18/10/2025';
    } else if (_selectedPeriod == 1) {
      totalStr = '~35h';
      subStr = 'Semana: 7-13/12/2025';
    } else {
      totalStr = '~140h';
      subStr = 'Mês: 12/2025';
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
                  maxX: 6,
                  minY: 0,
                  maxY: 6,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getChartSpots(),
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

  List<FlSpot> _getChartSpots() {
    if (_selectedPeriod == 0) {
      return const [
        FlSpot(0, 1),
        FlSpot(1, 1.5),
        FlSpot(2, 3),
        FlSpot(3, 2),
        FlSpot(4, 4.5),
        FlSpot(5, 2.5),
        FlSpot(6, 4),
      ];
    } else if (_selectedPeriod == 1) {
      return const [
        FlSpot(0, 3),
        FlSpot(1, 5),
        FlSpot(2, 4),
        FlSpot(3, 2),
        FlSpot(4, 5.5),
        FlSpot(5, 4.2),
        FlSpot(6, 4.5),
      ];
    } else {
      return const [
        FlSpot(0, 4),
        FlSpot(1, 3.5),
        FlSpot(2, 5),
        FlSpot(3, 3),
        FlSpot(4, 4.8),
        FlSpot(5, 4.5),
        FlSpot(6, 5.2),
      ];
    }
  }

  Widget _buildAppListCard() {
    List<Map<String, String>> appsData = [];

    if (_selectedPeriod == 0) {
      appsData = [
        {'name': 'Instagram', 'time': '1h33'},
        {'name': 'TikTok', 'time': '0h47'},
        {'name': 'WhatsApp', 'time': '0h38'},
      ];
    } else if (_selectedPeriod == 1) {
      appsData = [
        {'name': 'Instagram', 'time': '10h22'},
        {'name': 'TikTok', 'time': '5h27'},
        {'name': 'WhatsApp', 'time': '4h17'},
      ];
    } else {
      appsData = [
        {'name': 'Instagram', 'time': '48h03'},
        {'name': 'TikTok', 'time': '24h12'},
        {'name': 'WhatsApp', 'time': '19h36'},
      ];
    }

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
