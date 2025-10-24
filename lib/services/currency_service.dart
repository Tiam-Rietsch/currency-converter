// ═══════════════════════════════════════════════════════════════════════════
// CURRENCY SERVICE FILE
// ═══════════════════════════════════════════════════════════════════════════
// This file handles all communication with the external currency exchange
// rate API. Think of it as a bridge between our app and the internet.
//
//  PURPOSE: To fetch real-time currency exchange rates from an online API
//            and provide them to our app in a clean, easy-to-use format.
//
//  KEY CONCEPTS:
//    - HTTP Requests: Asking the internet for data
//    - Async/Await: Waiting for slow operations (like internet requests)
//    - JSON: Format for sending/receiving data over the internet
//    - Error Handling: Dealing with problems (no internet, bad data, etc.)
// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// IMPORTS - Bringing in external functionality
// ═══════════════════════════════════════════════════════════════════════════

/// dart:convert library
///  PURPOSE: To convert JSON (text) data into Dart objects we can use
///
/// WHAT IS JSON?
/// JSON = JavaScript Object Notation
/// - A text format for sending data over the internet
/// - Looks like: {"name": "John", "age": 30}
/// - Nearly all web APIs use JSON
/// - We need to "decode" (convert) it into Dart data types
///
/// FUNCTIONS WE USE:
/// - json.decode() → Converts JSON string to Dart Map/List
/// - Example: '{"rate": 1.5}' becomes {rate: 1.5}
import 'dart:convert';

/// http package
///  PURPOSE: To make HTTP requests to web servers (fetch data from internet)
///
/// WHAT IS HTTP?
/// HTTP = HyperText Transfer Protocol
/// - The language browsers and servers use to communicate
/// - We use it to request data from the currency API
///
/// WHY 'as http'?
/// - Creates an alias/nickname for the package
/// - Lets us write: http.get() instead of just get()
/// - Makes code clearer about where functions come from
/// - Avoids name conflicts with other packages
///
/// FUNCTIONS WE USE:
/// - http.get() → Makes a GET request to fetch data from a URL
import 'package:http/http.dart' as http;

// ═══════════════════════════════════════════════════════════════════════════
// CURRENCY SERVICE CLASS
// ═══════════════════════════════════════════════════════════════════════════
// This class contains all the methods (functions) we need to get exchange
// rate data from the internet.
//
// ARCHITECTURE NOTE:
// This is called a "Service" or "Repository" pattern
// - Separates network logic from UI logic
// - Makes code more organized and testable
// - If we change APIs, we only update this file
// ═══════════════════════════════════════════════════════════════════════════

/// A service class that handles all currency exchange rate operations
///
/// USAGE EXAMPLE:
/// ```dart
/// CurrencyService service = CurrencyService();
/// double rate = await service.getExchangeRate('USD', 'EUR');
/// ```
class CurrencyService {

  // ═════════════════════════════════════════════════════════════════════════
  // API CONFIGURATION
  // ═════════════════════════════════════════════════════════════════════════

  /// The base URL for the exchange rate API
  ///
  /// API DETAILS:
  /// - Provider: exchangerate-api.com
  /// - Tier: Free (no API key required)
  /// - Rate Limit: 1,500 requests per month
  /// - Data Update: Updates daily
  /// - Endpoint Pattern: /v4/latest/{BASE_CURRENCY}
  ///
  /// 📝 EXAMPLE URL:
  /// https://api.exchangerate-api.com/v4/latest/USD
  /// This returns all exchange rates with USD as the base
  ///
  ///  KEYWORDS:
  ///
  /// 'static':
  /// - Shared across all instances of CurrencyService
  /// - Only one copy in memory, not per object
  /// - Accessed via: CurrencyService._baseUrl
  /// - Makes sense for data that's the same for all instances
  ///
  /// 'const':
  /// - Compile-time constant (never changes)
  /// - More efficient than regular variables
  /// - Perfect for URLs, API keys, configuration
  ///
  /// Underscore prefix '_':
  /// - Makes this variable private to this file only
  /// - Can't be accessed from other files
  /// - Convention: _ means "internal/private"
  /// - Good for hiding implementation details
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest';

  // ═════════════════════════════════════════════════════════════════════════
  // METHOD 1: GET EXCHANGE RATE BETWEEN TWO CURRENCIES
  // ═════════════════════════════════════════════════════════════════════════

  /// Fetches the current exchange rate from one currency to another
  ///
  ///  PARAMETERS:
  /// - [from] The source currency code (e.g., 'USD')
  /// - [to] The target currency code (e.g., 'EUR')
  ///
  /// 📤 RETURNS:
  /// A Future<double> containing the exchange rate
  /// Example: If USD to EUR rate is 0.85, returns 0.85
  ///
  /// USAGE:
  /// ```dart
  /// double rate = await service.getExchangeRate('USD', 'EUR');
  /// // rate might be 0.85 (meaning 1 USD = 0.85 EUR)
  /// ```
  ///
  ///  KEYWORD: Future<double>
  ///
  /// What is a Future?
  /// - Represents a value that will be available "in the future"
  /// - Like a promise: "I'll give you the answer, but not right now"
  /// - Used for operations that take time (network, file I/O, etc.)
  /// - Must be awaited with 'await' keyword
  ///
  /// Why Future<double>?
  /// - The network request takes time (could be seconds)
  /// - We can't pause the whole app waiting for it
  /// - Future lets other code run while we wait
  /// - When data arrives, Future "completes" with the result
  ///
  /// Think of it like:
  /// - Ordering food at a restaurant (Future)
  /// - You get a number (the Future object)
  /// - You wait and do other things
  /// - When ready, you get your food (the double value)
  ///
  ///  KEYWORD: async
  ///
  /// What does 'async' do?
  /// - Marks this function as asynchronous
  /// - Allows use of 'await' inside the function
  /// - Automatically wraps return value in a Future
  /// - Required when doing asynchronous operations
  ///
  /// Without async: Can't use await, can't wait for network
  /// With async: Can pause at 'await' and resume when data arrives
  Future<double> getExchangeRate(String from, String to) async {

    // ═══════════════════════════════════════════════════════════════════════
    // ERROR HANDLING with try-catch
    // ═══════════════════════════════════════════════════════════════════════
    // Network requests can fail for many reasons:
    // - No internet connection
    // - Server is down
    // - Bad URL
    // - Timeout
    // We use try-catch to handle these gracefully

    try {
      // ═════════════════════════════════════════════════════════════════════
      // STEP 1: Make HTTP GET Request
      // ═════════════════════════════════════════════════════════════════════

      /// Build the complete URL and fetch data from the API
      ///
      /// URL CONSTRUCTION:
      /// '$_baseUrl/$from' combines:
      /// - _baseUrl: https://api.exchangerate-api.com/v4/latest
      /// - /: path separator
      /// - $from: currency code (e.g., 'USD')
      /// Final URL: https://api.exchangerate-api.com/v4/latest/USD
      ///
      /// Uri.parse():
      /// - Converts string URL into a Uri object
      /// - Uri is Dart's representation of a web address
      /// - Handles encoding, validation, etc.
      ///
      /// await http.get():
      /// - Makes an HTTP GET request to the URL
      /// - 'await' pauses here until server responds
      /// - Could take 100ms to several seconds
      /// - Returns a Response object with the data
      ///
      /// 'final response':
      /// - Stores the server's response
      /// - Contains: status code, headers, body (data)
      /// - 'final' because we won't reassign it
      final response = await http.get(Uri.parse('$_baseUrl/$from'));

      // ═════════════════════════════════════════════════════════════════════
      // STEP 2: Check if request was successful
      // ═════════════════════════════════════════════════════════════════════

      /// HTTP Status Codes:
      /// - 200: OK (success! we got the data)
      /// - 404: Not Found (invalid URL or currency)
      /// - 500: Server Error (API is broken)
      /// - 403: Forbidden (no permission/API key invalid)
      ///
      /// We only proceed if status is 200 (success)
      if (response.statusCode == 200) {

        // ═══════════════════════════════════════════════════════════════════
        // STEP 3: Parse JSON response
        // ═══════════════════════════════════════════════════════════════════

        /// response.body contains JSON text like this:
        /// {
        ///   "base": "USD",
        ///   "date": "2025-01-15",
        ///   "rates": {
        ///     "EUR": 0.85,
        ///     "GBP": 0.73,
        ///     "JPY": 110.5,
        ///     ... more currencies
        ///   }
        /// }
        ///
        /// json.decode():
        /// - Converts JSON string to Dart Map
        /// - Now we can access: data['rates'], data['base'], etc.
        /// - 'final data' becomes a Map<String, dynamic>
        final data = json.decode(response.body);

        /// Extract the 'rates' object from the JSON
        ///
        /// data['rates']:
        /// - Gets the rates object from the response
        /// - Contains all currency rates as key-value pairs
        ///
        /// 'as Map<String, dynamic>':
        /// - Type cast to tell Dart this is a Map
        /// - Map<String, dynamic> means:
        ///   - Keys are Strings (currency codes: "EUR", "GBP")
        ///   - Values are dynamic (could be int, double, etc.)
        /// - Gives us type safety and auto-complete
        final rates = data['rates'] as Map<String, dynamic>;

        /// Get the specific rate we want
        ///
        /// rates[to]:
        /// - Looks up the target currency in the rates map
        /// - Example: if to = 'EUR', gets rates['EUR']
        /// - Might return: 0.85 or null (if currency doesn't exist)
        ///
        /// ?.toDouble():
        /// - ? is null-aware operator
        /// - Only calls toDouble() if rates[to] is not null
        /// - Converts the value to a double
        /// - If null, this part returns null
        ///
        /// ?? 1.0:
        /// - Null coalescing operator
        /// - If left side is null, use right side (1.0)
        /// - Fallback value in case currency not found
        /// - 1.0 means "no conversion" (1 USD = 1 USD)
        ///
        /// COMPLETE FLOW:
        /// rates[to]?.toDouble() ?? 1.0
        /// If to='EUR': rates['EUR'].toDouble() → 0.85
        /// If to='XYZ' (not found): null → 1.0 (fallback)
        return rates[to]?.toDouble() ?? 1.0;

      } else {
        // ═══════════════════════════════════════════════════════════════════
        // STEP 4: Handle HTTP errors
        // ═══════════════════════════════════════════════════════════════════

        /// If status code is not 200, something went wrong
        /// Throw an exception to signal the error
        ///
        /// throw Exception():
        /// - Creates and throws an error
        /// - Stops execution of this function
        /// - Jumps to the catch block below
        /// - Error message helps with debugging
        throw Exception('Failed to load exchange rate');
      }

    } catch (e) {
      // ═════════════════════════════════════════════════════════════════════
      // STEP 5: Catch and re-throw errors
      // ═════════════════════════════════════════════════════════════════════

      /// This catches ANY error that happens above:
      /// - Network errors (no connection)
      /// - JSON parsing errors (bad data)
      /// - The Exception we threw
      ///
      /// 'e' contains the error details
      ///
      /// We re-throw with more context:
      /// - Original error message is appended
      /// - Helps identify what went wrong
      /// - Calling code can display this to user
      throw Exception('Error fetching exchange rate: $e');
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // METHOD 2: GET ALL EXCHANGE RATES FOR A BASE CURRENCY
  // ═════════════════════════════════════════════════════════════════════════

  /// Fetches ALL exchange rates for a given base currency
  ///
  ///  PARAMETERS:
  /// - [baseCurrency] The currency to use as base (e.g., 'USD')
  ///
  ///  RETURNS:
  /// A Future<Map<String, double>> containing all rates
  /// Example: {'EUR': 0.85, 'GBP': 0.73, 'JPY': 110.5, ...}
  ///
  ///  USAGE:
  /// ```dart
  /// Map<String, double> rates = await service.getAllRates('USD');
  /// double eurRate = rates['EUR']; // Get EUR rate from map
  /// ```
  ///
  ///  WHY THIS METHOD?
  /// - Efficient when you need rates for multiple currencies
  /// - One API call instead of many
  /// - Used in Exchange Analysis screen to show all rates
  ///
  ///  Map<String, double>:
  /// - Map is like a dictionary/hash table
  /// - Key-value pairs: currency code → rate
  /// - String = currency code ('EUR', 'GBP')
  /// - double = exchange rate (0.85, 0.73)
  Future<Map<String, double>> getAllRates(String baseCurrency) async {
    try {
      // Same HTTP request as before, but we'll process all rates
      // URL example: .../v4/latest/USD (gets all rates for USD)
      final response = await http.get(Uri.parse('$_baseUrl/$baseCurrency'));

      if (response.statusCode == 200) {
        // Decode JSON response
        final data = json.decode(response.body);

        // Extract rates object
        // This contains ALL currencies with their rates
        final rates = data['rates'] as Map<String, dynamic>;

        /// Transform the rates Map to ensure all values are doubles
        ///
        /// rates.map((key, value) => ...):
        /// - Iterates through each key-value pair
        /// - Transforms each pair using the function
        /// - Returns a new Map
        ///
        /// MapEntry(key, value.toDouble()):
        /// - Creates a new map entry
        /// - key stays the same (currency code)
        /// - value.toDouble() converts to double
        /// - Ensures type safety (all values are double)
        ///
        /// WHY?
        /// - JSON numbers might be int or double
        /// - We want consistent double type
        /// - Prevents type errors later
        ///
        /// EXAMPLE TRANSFORMATION:
        /// Input:  {'EUR': 0.85, 'JPY': 110}  (mixed int/double)
        /// Output: {'EUR': 0.85, 'JPY': 110.0} (all double)
        return rates.map((key, value) => MapEntry(key, value.toDouble()));

      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      throw Exception('Error fetching exchange rates: $e');
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // METHOD 3: CONVERT AMOUNT FROM ONE CURRENCY TO ANOTHER
  // ═════════════════════════════════════════════════════════════════════════

  /// Converts a specific amount from one currency to another
  ///
  /// PARAMETERS:
  /// - [amount] The amount to convert (e.g., 100.0)
  /// - [from] The source currency (e.g., 'USD')
  /// - [to] The target currency (e.g., 'EUR')
  ///
  /// RETURNS:
  /// Future<double> with the converted amount
  /// Example: 100 USD → 85.0 EUR (if rate is 0.85)
  ///
  /// USAGE:
  /// ```dart
  /// double converted = await service.convertCurrency(100, 'USD', 'EUR');
  /// // If rate is 0.85: converted = 85.0
  /// ```
  ///
  /// MATH:
  /// Converted Amount = Original Amount × Exchange Rate
  /// If 1 USD = 0.85 EUR:
  /// 100 USD = 100 × 0.85 = 85.0 EUR
  ///
  /// NOTE: This is a convenience method
  /// - Combines getExchangeRate() with multiplication
  /// - Makes converter screen code cleaner
  /// - Shows good API design (high-level + low-level methods)
  Future<double> convertCurrency(
    double amount,
    String from,
    String to,
  ) async {
    // STEP 1: Get the exchange rate
    // 'await' because getExchangeRate is async
    // This might take a second or two (network call)
    final rate = await getExchangeRate(from, to);

    // STEP 2: Multiply amount by rate
    // Simple math: amount × rate = converted amount
    // Example: 100 × 0.85 = 85.0
    return amount * rate;
  }

  /// Get historical rates for the past 7 days
  Future<Map<String, List<double>>> getHistoricalRates(
    String baseCurrency,
    String targetCurrency,
  ) async {
    try {
      // Frankfurter API doesn't support some currencies like XAF
      // Fall back to using current rate API for unsupported currencies
      final unsupportedCurrencies = ['XAF', 'RUB']; // Add more if needed

      if (unsupportedCurrencies.contains(baseCurrency) ||
          unsupportedCurrencies.contains(targetCurrency)) {
        // Use fallback: get current rate and generate mock historical data
        return _getFallbackHistoricalRates(baseCurrency, targetCurrency);
      }

      final today = DateTime.now();
      final result = <String, List<double>>{
        'dates': [],
        'rates': [],
      };

      // Fetch rates for past 7 days
      for (int i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

        try {
          // Using frankfurter API for historical data (free, no key needed)
          final response = await http.get(
            Uri.parse('https://api.frankfurter.app/$dateStr?from=$baseCurrency&to=$targetCurrency'),
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final rates = data['rates'] as Map<String, dynamic>;
            result['rates']!.add(rates[targetCurrency]?.toDouble() ?? 1.0);
            result['dates']!.add(i.toDouble());
          } else {
            // API error, use fallback
            return _getFallbackHistoricalRates(baseCurrency, targetCurrency);
          }
        } catch (e) {
          // If one day fails, try next day or use fallback
          if (result['rates']!.isEmpty) {
            return _getFallbackHistoricalRates(baseCurrency, targetCurrency);
          }
          result['rates']!.add(result['rates']!.last);
          result['dates']!.add(i.toDouble());
        }
      }

      return result;
    } catch (e) {
      throw Exception('Error fetching historical rates: $e');
    }
  }

  /// Fallback method for unsupported currencies
  Future<Map<String, List<double>>> _getFallbackHistoricalRates(
    String baseCurrency,
    String targetCurrency,
  ) async {
    try {
      // Get current rate
      final currentRate = await getExchangeRate(baseCurrency, targetCurrency);

      // Generate mock historical data with small variations around current rate
      final result = <String, List<double>>{
        'dates': [],
        'rates': [],
      };

      for (int i = 6; i >= 0; i--) {
        // Add small random variation (±2%)
        final variation = (i * 0.003) - 0.009; // Creates a slight trend
        final rate = currentRate * (1 + variation);
        result['rates']!.add(rate);
        result['dates']!.add(i.toDouble());
      }

      return result;
    } catch (e) {
      throw Exception('Error generating fallback rates: $e');
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  HOW THIS SERVICE CONNECTS TO THE REST OF THE APP
// ═══════════════════════════════════════════════════════════════════════════
//
// CONVERTER SCREEN (converter_screen.dart):
//    ├─ Creates instance: CurrencyService _service = CurrencyService()
//    ├─ Calls convertCurrency() when user enters amount
//    ├─ Calls getExchangeRate() to show exchange rate info
//    └─ Displays loading indicator while awaiting results
//
// EXCHANGE ANALYSIS SCREEN (exchange_analysis_screen.dart):
//    ├─ Creates instance: CurrencyService _service = CurrencyService()
//    ├─ Calls getAllRates() to fetch all rates at once
//    ├─ Displays rates in cards for multiple currencies
//    └─ Updates when user changes base currency
//
// ERROR HANDLING FLOW:
//    User enters amount → Screen calls service → Service makes HTTP request
//         ↓                                            ↓
//    If error: Shows SnackBar with message    API fails or no internet
//         ↑                                            ↓
//    Screen catches exception ← Service throws exception
//
// ═══════════════════════════════════════════════════════════════════════════
// COMPLETE DATA FLOW EXAMPLE
// ═══════════════════════════════════════════════════════════════════════════
//
// USER ACTION: Types "100" and selects USD → EUR
//    ↓
// 1. Converter screen calls:
//    service.convertCurrency(100, 'USD', 'EUR')
//    ↓
// 2. Service makes HTTP request:
//    GET https://api.exchangerate-api.com/v4/latest/USD
//    ↓
// 3. Server responds with JSON:
//    {"base": "USD", "rates": {"EUR": 0.85, ...}}
//    ↓
// 4. Service extracts rate:
//    rate = 0.85
//    ↓
// 5. Service calculates:
//    100 × 0.85 = 85.0
//    ↓
// 6. Service returns:
//    Future completes with 85.0
//    ↓
// 7. Screen receives result:
//    Updates UI to show "85.0 EUR"
//
// IF ERROR (no internet):
//    ↓
// Service throws exception → Screen catches → Shows error SnackBar
//
// ═══════════════════════════════════════════════════════════════════════════
// 🎓 KEY CONCEPTS DEMONSTRATED
// ═══════════════════════════════════════════════════════════════════════════
//
// Async/Await: Handling operations that take time
//  Futures: Representing values that arrive later
// HTTP Requests: Fetching data from internet
// JSON Parsing: Converting text data to Dart objects
// Error Handling: try-catch for network failures
// Type Safety: Explicit types (Map<String, double>)
// Service Pattern: Separating business logic from UI
// API Integration: Working with external data sources
// Null Safety: Using ?. and ?? operators
//
// ═══════════════════════════════════════════════════════════════════════════
