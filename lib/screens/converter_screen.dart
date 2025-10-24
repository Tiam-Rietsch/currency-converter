import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import '../models/currency.dart';
import '../services/currency_service.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final CurrencyService _currencyService = CurrencyService();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  Currency _fromCurrency = CurrencyData.currencies[0]; // USD
  Currency _toCurrency = CurrencyData.currencies[1]; // EUR

  bool _isLoading = false;
  double _exchangeRate = 0.0;
  bool _isFromFieldActive = true;

  @override
  void initState() {
    super.initState();
    _fromController.text = '1';
    _convertCurrency();
  }

  Future<void> _convertCurrency() async {
    if (_fromController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_fromController.text);
      final result = await _currencyService.convertCurrency(
        amount,
        _fromCurrency.code,
        _toCurrency.code,
      );
      _exchangeRate = await _currencyService.getExchangeRate(
        _fromCurrency.code,
        _toCurrency.code,
      );

      setState(() {
        _toController.text = result.toStringAsFixed(2);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF6B35),
          ),
        );
      }
    }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;

      final tempText = _fromController.text;
      _fromController.text = _toController.text;
      _toController.text = tempText;
    });
    _convertCurrency();
  }

  void _onKeyboardTap(String value) {
    final controller = _isFromFieldActive ? _fromController : _toController;
    
    if (value == '⌫') {
      if (controller.text.isNotEmpty) {
        controller.text = controller.text.substring(0, controller.text.length - 1);
      }
    } else if (value == 'C') {
      controller.text = '';
    } else {
      // Prevent multiple decimal points
      if (value == '.' && controller.text.contains('.')) return;
      controller.text += value;
    }
    
    if (_isFromFieldActive) {
      _convertCurrency();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight / 3;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Title
            const Text(
              'Currency Converter',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Converter Card - 1/3 of screen height
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                child: SizedBox(
                  height: cardHeight,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // FROM Currency
                        _buildCurrencyInput(
                          controller: _fromController,
                          currency: _fromCurrency,
                          onCurrencyChanged: (Currency? newCurrency) {
                            if (newCurrency != null) {
                              setState(() => _fromCurrency = newCurrency);
                              _convertCurrency();
                            }
                          },
                          isActive: _isFromFieldActive,
                          onTap: () => setState(() => _isFromFieldActive = true),
                        ),

                        // Exchange Icon
                        GestureDetector(
                          onTap: _swapCurrencies,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF6B35),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.swap_vert,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),

                        // TO Currency
                        Column(
                          children: [
                            _buildCurrencyInput(
                              controller: _toController,
                              currency: _toCurrency,
                              onCurrencyChanged: (Currency? newCurrency) {
                                if (newCurrency != null) {
                                  setState(() => _toCurrency = newCurrency);
                                  _convertCurrency();
                                }
                              },
                              isActive: !_isFromFieldActive,
                              onTap: () => setState(() => _isFromFieldActive = false),
                            ),
                            
                            // Exchange Rate Display
                            if (_exchangeRate > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '1 ${_fromCurrency.code} = ${_exchangeRate.toStringAsFixed(4)} ${_toCurrency.code}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Custom Keyboard
            _buildCustomKeyboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyInput({
    required TextEditingController controller,
    required Currency currency,
    required ValueChanged<Currency?> onCurrencyChanged,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    // Handle EU flag for EUR
    String flagCode = currency.code == 'EUR' ? 'eu' : currency.countryCode;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2A2A2A) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? const Color(0xFFFF6B35) : const Color(0xFF2A2A2A),
            width: isActive ? 2 : 1,
          ),
        ),
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
              child: flagCode == 'EU'
                  ? _buildEUFlag()
                  : CountryFlag.fromCountryCode(flagCode),
            ),
            const SizedBox(width: 12),

            // Currency Dropdown and Amount
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Currency Selector
                  GestureDetector(
                    onTap: () => _showCurrencyPicker(onCurrencyChanged),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${currency.code} - ${currency.name}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFFFF6B35),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Amount Display
                  Text(
                    controller.text.isEmpty ? '0' : controller.text,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(ValueChanged<Currency?> onCurrencyChanged) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: ListView.builder(
            itemCount: CurrencyData.currencies.length,
            itemBuilder: (context, index) {
              final currency = CurrencyData.currencies[index];
              String flagCode = currency.code == 'EUR' ? 'eu' : currency.countryCode;
              
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: flagCode == 'EU'
                      ? _buildEUFlag()
                      : CountryFlag.fromCountryCode(flagCode),
                ),
                title: Text(
                  currency.code,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  currency.name,
                  style: const TextStyle(color: Colors.white60),
                ),
                onTap: () {
                  onCurrencyChanged(currency);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCustomKeyboard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildKeyboardRow(['1', '2', '3']),
          _buildKeyboardRow(['4', '5', '6']),
          _buildKeyboardRow(['7', '8', '9']),
          _buildKeyboardRow(['.', '0', '⌫']),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((key) => _buildKey(key)).toList(),
      ),
    );
  }

  Widget _buildKey(String key) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: key == '⌫' ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () => _onKeyboardTap(key),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 50,
              alignment: Alignment.center,
              child: Text(
                key,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: key == '⌫' ? Colors.white : const Color(0xFF0D0D0D),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEUFlag() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF003399), // EU Blue
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circle of 12 stars (simplified for circular display)
          for (int i = 0; i < 12; i++)
            Transform.rotate(
              angle: (i * 30) * 3.14159 / 180,
              child: Transform.translate(
                offset: const Offset(0, -12),
                child: const Icon(
                  Icons.star,
                  color: Color(0xFFFFCC00), // EU Yellow
                  size: 4,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }
}
