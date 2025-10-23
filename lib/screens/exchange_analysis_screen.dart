import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:country_flags/country_flags.dart';
import '../models/currency.dart';
import '../services/currency_service.dart';

class ExchangeAnalysisScreen extends StatefulWidget {
  const ExchangeAnalysisScreen({super.key});

  @override
  State<ExchangeAnalysisScreen> createState() => _ExchangeAnalysisScreenState();
}

class _ExchangeAnalysisScreenState extends State<ExchangeAnalysisScreen> {
  final CurrencyService _currencyService = CurrencyService();
  Currency _baseCurrency = CurrencyData.currencies[0]; // USD
  Map<String, double> _rates = {};
  bool _isLoading = false;
  String _selectedPeriod = '7D';

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    setState(() => _isLoading = true);

    try {
      final rates = await _currencyService.getAllRates(_baseCurrency.code);
      setState(() {
        _rates = rates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading rates: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF6B35),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF6B35),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Title and Base Currency Selector
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Exchange Analysis',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF2A2A2A)),
                            ),
                            child: DropdownButton<Currency>(
                              value: _baseCurrency,
                              underline: const SizedBox(),
                              isDense: true,
                              dropdownColor: const Color(0xFF1A1A1A),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              items: CurrencyData.currencies.map((Currency curr) {
                                return DropdownMenuItem<Currency>(
                                  value: curr,
                                  child: Text(curr.code),
                                );
                              }).toList(),
                              onChanged: (Currency? newCurrency) {
                                if (newCurrency != null) {
                                  setState(() => _baseCurrency = newCurrency);
                                  _loadRates();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Chart Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Historical Trend',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Time Period Selector
                              Row(
                                children: ['24H', '7D', '1M', '1Y'].map((period) {
                                  final isSelected = _selectedPeriod == period;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: GestureDetector(
                                      onTap: () => setState(() => _selectedPeriod = period),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFFFF6B35)
                                              : const Color(0xFF2A2A2A),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          period,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.white70,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 20),

                              // Chart
                              SizedBox(
                                height: 200,
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: 1,
                                      getDrawingHorizontalLine: (value) {
                                        return const FlLine(
                                          color: Color(0xFF2A2A2A),
                                          strokeWidth: 1,
                                        );
                                      },
                                    ),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          interval: 1,
                                          getTitlesWidget: (value, meta) {
                                            const style = TextStyle(
                                              color: Colors.white60,
                                              fontSize: 12,
                                            );
                                            Widget text;
                                            switch (value.toInt()) {
                                              case 0:
                                                text = const Text('Mon', style: style);
                                                break;
                                              case 2:
                                                text = const Text('Wed', style: style);
                                                break;
                                              case 4:
                                                text = const Text('Fri', style: style);
                                                break;
                                              case 6:
                                                text = const Text('Sun', style: style);
                                                break;
                                              default:
                                                text = const Text('', style: style);
                                                break;
                                            }
                                            return SideTitleWidget(
                                              meta: meta,
                                              child: text,
                                            );
                                          },
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 40,
                                          interval: 0.5,
                                          getTitlesWidget: (value, meta) {
                                            return Text(
                                              value.toStringAsFixed(1),
                                              style: const TextStyle(
                                                color: Colors.white60,
                                                fontSize: 12,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    minX: 0,
                                    maxX: 6,
                                    minY: 0,
                                    maxY: 3,
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: _generateSampleData(),
                                        isCurved: true,
                                        color: const Color(0xFFFF6B35),
                                        barWidth: 3,
                                        isStrokeCapRound: true,
                                        dotData: const FlDotData(show: false),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: const Color(0xFFFF6B35)
                                              .withOpacity(0.2),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Currency Comparison Cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Exchange Rates',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Rate Cards
                          ...CurrencyData.currencies
                              .where((curr) => curr.code != _baseCurrency.code)
                              .take(6)
                              .map((currency) => _buildRateCard(currency)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildRateCard(Currency currency) {
    final rate = _rates[currency.code] ?? 0.0;
    final changePercent = (rate * 0.05 - 0.025) * 100; // Mock percentage change
    String flagCode = currency.code == 'EUR' ? 'eu' : currency.countryCode;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Circular Flag
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: CountryFlag.fromCountryCode(flagCode),
            ),
            const SizedBox(width: 16),

            // Currency Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currency.code,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currency.name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),

            // Rate and Change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  rate.toStringAsFixed(4),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: changePercent >= 0
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        changePercent >= 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 12,
                        color: changePercent >= 0 ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${changePercent.abs().toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: changePercent >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateSampleData() {
    // Generate sample data for the chart
    return [
      const FlSpot(0, 1.5),
      const FlSpot(1, 1.8),
      const FlSpot(2, 1.6),
      const FlSpot(3, 2.1),
      const FlSpot(4, 1.9),
      const FlSpot(5, 2.3),
      const FlSpot(6, 2.0),
    ];
  }
}
