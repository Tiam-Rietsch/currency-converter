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
  Currency _baseCurrency = CurrencyData.currencies[1]; // USD
  Currency _selectedCurrency = CurrencyData.currencies[2]; // EUR - default selected
  Map<String, double> _rates = {};
  List<double> _historicalRates = [];
  List<double> _historicalDates = [];
  bool _isLoading = false;
  bool _isLoadingChart = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load current rates
      final rates = await _currencyService.getAllRates(_baseCurrency.code);

      setState(() {
        _rates = rates;
        _isLoading = false;
      });

      // Load historical data for chart
      _loadHistoricalData();
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

  Future<void> _loadHistoricalData() async {
    setState(() => _isLoadingChart = true);

    try {
      final historical = await _currencyService.getHistoricalRates(
        _baseCurrency.code,
        _selectedCurrency.code,
      );

      setState(() {
        _historicalDates = historical['dates']!;
        _historicalRates = historical['rates']!;
        _isLoadingChart = false;
      });
    } catch (e) {
      setState(() => _isLoadingChart = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading chart: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF6B35),
          ),
        );
      }
    }
  }

  void _onCurrencyCardTap(Currency currency) {
    setState(() {
      _selectedCurrency = currency;
    });
    _loadHistoricalData();
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
                              fontSize: 24,
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
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
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
                                  _loadData();
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
                        elevation: 0,
                        color: const Color(0xFF1A1A1A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Historical Trend (7 Days)',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${_baseCurrency.code}/${_selectedCurrency.code}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFFFF6B35),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Chart
                              SizedBox(
                                height: 200,
                                child: _isLoadingChart
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFFFF6B35),
                                        ),
                                      )
                                    : _historicalRates.isEmpty
                                        ? const Center(
                                            child: Text(
                                              'No data available',
                                              style: TextStyle(color: Colors.grey),
                                            ),
                                          )
                                        : LineChart(
                                            LineChartData(
                                              gridData: FlGridData(
                                                show: true,
                                                drawVerticalLine: false,
                                                horizontalInterval: null,
                                                getDrawingHorizontalLine: (value) {
                                                  return FlLine(
                                                    color: const Color(0xFF2A2A2A),
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
                                                      final index = value.toInt();
                                                      // Only show labels for first, middle, and last points
                                                      if (index == 0 ||
                                                          index == (_historicalRates.length / 2).floor() ||
                                                          index == _historicalRates.length - 1) {
                                                        final today = DateTime.now();
                                                        final date = today.subtract(Duration(days: _historicalRates.length - 1 - index));
                                                        final dayName = _getDayName(date.weekday);
                                                        return SideTitleWidget(
                                                          meta: meta,
                                                          child: Text(
                                                            dayName,
                                                            style: const TextStyle(
                                                              color: Colors.grey,
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                      return const SizedBox();
                                                    },
                                                  ),
                                                ),
                                                leftTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,
                                                    reservedSize: 45,
                                                    getTitlesWidget: (value, meta) {
                                                      return Text(
                                                        value.toStringAsFixed(3),
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 10,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              borderData: FlBorderData(show: false),
                                              minX: 0,
                                              maxX: (_historicalRates.length + 1).toDouble(),
                                              lineBarsData: [
                                                // Historical data line
                                                LineChartBarData(
                                                  spots: _buildHistoricalSpots(),
                                                  isCurved: true,
                                                  color: _getTrendColor(),
                                                  barWidth: 3,
                                                  isStrokeCapRound: true,
                                                  dotData: FlDotData(
                                                    show: true,
                                                    getDotPainter: (spot, percent, barData, index) {
                                                      return FlDotCirclePainter(
                                                        radius: 3,
                                                        color: _getTrendColor(),
                                                        strokeWidth: 0,
                                                      );
                                                    },
                                                  ),
                                                  belowBarData: BarAreaData(
                                                    show: true,
                                                    color: _getTrendColor().withOpacity(0.1),
                                                  ),
                                                ),
                                                // Future projection line
                                                LineChartBarData(
                                                  spots: _buildFutureSpots(),
                                                  isCurved: true,
                                                  color: _getTrendColor().withOpacity(0.5),
                                                  barWidth: 2,
                                                  isStrokeCapRound: true,
                                                  dashArray: [5, 5],
                                                  dotData: const FlDotData(show: false),
                                                ),
                                              ],
                                            ),
                                          ),
                              ),

                              const SizedBox(height: 10),

                              // Legend
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLegendItem('Historical', _getTrendColor()),
                                  const SizedBox(width: 20),
                                  _buildLegendItem('Projection', _getTrendColor().withOpacity(0.7)),
                                ],
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
                            'Exchange Rates (Tap to compare)',
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

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  List<FlSpot> _buildHistoricalSpots() {
    if (_historicalRates.isEmpty) return [];

    return List.generate(
      _historicalRates.length,
      (index) => FlSpot(index.toDouble(), _historicalRates[index]),
    );
  }

  List<FlSpot> _buildFutureSpots() {
    if (_historicalRates.isEmpty || _historicalRates.length < 3) return [];

    // Simple linear projection based on last 3 points
    final lastRate = _historicalRates.last;
    final prevRate = _historicalRates[_historicalRates.length - 2];
    final trend = lastRate - prevRate;

    final lastIndex = _historicalRates.length - 1;

    return [
      FlSpot(lastIndex.toDouble(), lastRate),
      FlSpot((lastIndex + 1).toDouble(), lastRate + trend),
      FlSpot((lastIndex + 2).toDouble(), lastRate + (trend * 2)),
    ];
  }

  Color _getTrendColor() {
    if (_historicalRates.isEmpty || _historicalRates.length < 2) {
      return const Color(0xFFFF6B35); // Default orange
    }

    // Compare first and last rates to determine trend
    final firstRate = _historicalRates.first;
    final lastRate = _historicalRates.last;

    if (lastRate > firstRate) {
      return Colors.green; // Rate went up
    } else if (lastRate < firstRate) {
      return Colors.red; // Rate went down
    } else {
      return const Color(0xFFFF6B35); // No change - orange
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  Widget _buildEUFlag() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF003399), // EU Blue
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circle of 12 stars
          for (int i = 0; i < 12; i++)
            Transform.translate(
              offset: Offset(
                15 * (i < 6 ? i - 2.5 : i - 8.5),
                i < 6 ? -8 : 8,
              ),
              child: const Icon(
                Icons.star,
                color: Color(0xFFFFCC00), // EU Yellow
                size: 6,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRateCard(Currency currency) {
    final rate = _rates[currency.code] ?? 0.0;
    final changePercent = (rate * 0.05 - 0.025) * 100; // Mock percentage change
    final isSelected = _selectedCurrency.code == currency.code;

    return GestureDetector(
      onTap: () => _onCurrencyCardTap(currency),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        color: isSelected ? const Color(0xFFFF6B35).withOpacity(0.1) : const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? const Color(0xFFFF6B35) : const Color(0xFF2A2A2A),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Country Flag
              SizedBox(
                height: 40,
                width: 50,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: currency.countryCode == 'EU'
                      ? _buildEUFlag()
                      : CountryFlag.fromCountryCode(
                          currency.countryCode,
                        ),
                ),
              ),
              const SizedBox(width: 16),

              // Currency Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currency.code,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? const Color(0xFFFF6B35) : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currency.name,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFFFF6B35) : Colors.white,
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
      ),
    );
  }
}
