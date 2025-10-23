// ═══════════════════════════════════════════════════════════════════════════
// CURRENCY MODEL FILE
// ═══════════════════════════════════════════════════════════════════════════
// This file defines the data structure (blueprint) for representing currencies
// in our application. Think of this as creating a custom data type.
//
// 🎯 PURPOSE: To organize currency information (code, name, country) into
//            reusable objects that can be passed around the app.
//
// 📚 DART CONCEPT: Models are classes that represent data. They help us
//                 organize related information together instead of having
//                 separate variables floating around.
// ═══════════════════════════════════════════════════════════════════════════

/// The Currency class is a blueprint/template for creating currency objects.
///
/// 💡 ANALOGY: Think of this like a form with three fields:
///    - code (e.g., "USD")
///    - name (e.g., "US Dollar")
///    - countryCode (e.g., "US")
///
/// Every time we create a Currency, we fill out this form with specific values.
class Currency {

  // ═════════════════════════════════════════════════════════════════════════
  // PROPERTIES (Fields/Attributes)
  // ═════════════════════════════════════════════════════════════════════════
  // These are the pieces of information that every Currency object will have.
  // ═════════════════════════════════════════════════════════════════════════

  /// The 3-letter currency code following ISO 4217 standard
  /// Examples: "USD", "EUR", "GBP", "JPY"
  ///
  /// WHY 'final'?
  /// - 'final' means this value can only be set ONCE (during creation)
  /// - After creation, it cannot be changed (immutable)
  /// - This is good because a currency's code shouldn't change
  /// - Example: Once we create USD, it should always remain USD
  ///
  /// NOTE: In Dart, 'final' is different from 'const':
  ///   - final = set once at runtime, can't change after
  ///   - const = set at compile time, never changes
  final String code;

  /// The full human-readable name of the currency
  /// Examples: "US Dollar", "Euro", "British Pound"
  ///
  /// PURPOSE: To show friendly names to users
  /// - "US Dollar" is easier to understand than just "USD"
  /// - Especially helpful for users unfamiliar with currency codes
  final String name;

  /// The 2-letter country code following ISO 3166-1 alpha-2 standard
  /// Examples: "US", "GB", "JP", "EU" (special case for Euro)
  ///
  /// PURPOSE: Used to display the correct flag for each currency
  /// - The country_flags package uses this to show flags
  /// - Special handling: "EU" shows European Union flag for Euro
  /// - Note: Some currencies like EUR aren't tied to one country
  final String countryCode;

  // ═════════════════════════════════════════════════════════════════════════
  // CONSTRUCTOR
  // ═════════════════════════════════════════════════════════════════════════
  // A special function that creates (constructs) new Currency objects
  // ═════════════════════════════════════════════════════════════════════════

  /// Creates a new Currency object with the provided information
  ///
  /// HOW TO USE:
  /// ```dart
  /// Currency usd = Currency(
  ///   code: 'USD',
  ///   name: 'US Dollar',
  ///   countryCode: 'US'
  /// );
  /// ```
  ///
  /// KEYWORD EXPLANATIONS:
  ///
  /// 'const' Constructor:
  /// - Allows creating compile-time constant objects
  /// - More efficient: Flutter creates it once and reuses it
  /// - Perfect for data that never changes (like currency definitions)
  /// - Saves memory because identical objects share the same memory space
  ///
  /// Named Parameters (the curly braces {}):
  /// - Makes code more readable: Currency(code: 'USD', name: '...')
  /// - Order doesn't matter: Currency(name: '...', code: 'USD') works too
  /// - Alternative would be positional: Currency('USD', '...', 'US')
  /// - Named parameters are clearer, especially with multiple parameters
  ///
  /// 'required' Keyword:
  /// - Marks parameters that MUST be provided
  /// - Dart will show an error if you forget to provide them
  /// - Prevents bugs from missing data
  /// - Example: Currency(code: 'USD') would error (missing name & countryCode)
  ///
  /// 'this.property' Syntax:
  /// - Shorthand for assigning constructor parameters to class properties
  /// - 'this.code' means "assign the parameter to the code property"
  /// - Long form would be: Currency({required String code}) : code = code;
  /// - Much cleaner and less repetitive
  const Currency({
    required this.code,
    required this.name,
    required this.countryCode,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// CURRENCY DATA CLASS
// ═══════════════════════════════════════════════════════════════════════════
// This class holds a predefined list of currencies that our app supports.
// It's like a mini-database stored directly in the code.
//
// PURPOSE: Provide easy access to a list of common world currencies
//            that users can select from in the app.
//
// WHY NOT just use a simple list variable?
//   - Organizing in a class makes it clear this data belongs together
//   - Easy to find and maintain (all currency data in one place)
//   - Can be accessed from anywhere: CurrencyData.currencies
// ═══════════════════════════════════════════════════════════════════════════

/// Static data holder for the list of supported currencies
///
/// WHAT IS A STATIC CLASS?
/// - A class that you never create instances of
/// - Just holds data and utility functions
/// - Access directly: CurrencyData.currencies (no need for 'new CurrencyData()')
/// - Think of it as a namespace or container for related data
class CurrencyData {

  /// A predefined list of 16 major world currencies
  ///
  /// KEYWORD EXPLANATIONS:
  ///
  /// 'static':
  /// - Belongs to the class itself, not to any instance
  /// - One single copy exists for the entire app
  /// - Accessed via class name: CurrencyData.currencies
  /// - Can't access with an instance: new CurrencyData().currencies 
  ///
  /// 'const':
  /// - This list is a compile-time constant (never changes)
  /// - Flutter creates this list when building the app
  /// - More efficient: saved in read-only memory
  /// - Can't add, remove, or modify currencies at runtime
  ///
  /// 'List<Currency>':
  /// - Declares this is a List (ordered collection/array)
  /// - <Currency> is a generic type parameter
  /// - Means: "This list can ONLY contain Currency objects"
  /// - Type safety: Can't accidentally add a String or Number
  /// - IDE will auto-complete Currency-specific properties
  ///
  /// CURRENCY SELECTION:
  /// These currencies were chosen based on:
  /// - Trading volume (USD, EUR, JPY are most traded)
  /// - Economic importance (major economies)
  /// - Geographic diversity (representing different regions)
  /// - User demand (commonly needed conversions)
  ///
  /// HOW IT'S USED IN THE APP:
  /// 1. Dropdown lists → Shows these currencies for user selection
  /// 2. Currency picker → User picks from this list
  /// 3. Exchange rates → Gets rates for these currencies
  /// 4. Display → Shows flags and names from this data
  static const List<Currency> currencies = [
    // XAF - Central African CFA Franc
    // Used by 6 Central African countries
    // Special case: First in list to show regional currency
    Currency(code: 'XAF', name: 'CFA Franc', countryCode: 'CM'),

    // USD - United States Dollar
    // World's primary reserve currency
    // Most traded currency globally (~88% of forex transactions)
    Currency(code: 'USD', name: 'US Dollar', countryCode: 'US'),

    // EUR - Euro
    // Second most traded currency (~31% of forex)
    // Used by 19 of 27 EU countries
    // Special: Uses 'EU' flag instead of specific country
    Currency(code: 'EUR', name: 'Euro', countryCode: 'EU'),

    // GBP - British Pound Sterling
    // One of the oldest currencies (over 1200 years old!)
    // Fourth most traded currency
    Currency(code: 'GBP', name: 'British Pound', countryCode: 'GB'),

    // JPY - Japanese Yen
    // Third most traded currency
    // Major safe-haven currency in times of market uncertainty
    Currency(code: 'JPY', name: 'Japanese Yen', countryCode: 'JP'),

    // CAD - Canadian Dollar
    // Nicknamed "Loonie" (bird on the $1 coin)
    // Closely tied to commodity prices (oil, timber)
    Currency(code: 'CAD', name: 'Canadian Dollar', countryCode: 'CA'),

    // AUD - Australian Dollar
    // Fifth most traded currency
    // Also commodity-linked (mining, agriculture)
    Currency(code: 'AUD', name: 'Australian Dollar', countryCode: 'AU'),

    // CHF - Swiss Franc
    // Known for stability and neutrality
    // Safe-haven currency (like gold)
    // Switzerland's strong banking sector
    Currency(code: 'CHF', name: 'Swiss Franc', countryCode: 'CH'),

    // CNY - Chinese Yuan (Renminbi)
    // Yuan = unit of account, Renminbi = currency name
    // Increasingly important in international trade
    // China is world's second largest economy
    Currency(code: 'CNY', name: 'Chinese Yuan', countryCode: 'CN'),

    // INR - Indian Rupee
    // Symbol: ₹
    // One of the oldest currency systems
    // Represents India's growing economy
    Currency(code: 'INR', name: 'Indian Rupee', countryCode: 'IN'),

    // MXN - Mexican Peso
    // Most traded currency in Latin America
    // Important for US-Mexico trade
    Currency(code: 'MXN', name: 'Mexican Peso', countryCode: 'MX'),

    // BRL - Brazilian Real
    // Named after Brazil's first official currency (1690)
    // Largest economy in South America
    Currency(code: 'BRL', name: 'Brazilian Real', countryCode: 'BR'),

    // ZAR - South African Rand
    // Named after Witwatersrand (ridge of gold)
    // Most traded currency in Africa
    Currency(code: 'ZAR', name: 'South African Rand', countryCode: 'ZA'),

    // RUB - Russian Ruble
    // One of the world's oldest currencies (13th century)
    // Symbol: ₽
    Currency(code: 'RUB', name: 'Russian Ruble', countryCode: 'RU'),

    // KRW - South Korean Won
    // Symbol: ₩
    // Important in Asian electronics and automotive trade
    Currency(code: 'KRW', name: 'South Korean Won', countryCode: 'KR'),

    // SGD - Singapore Dollar
    // One of the strongest and most stable Asian currencies
    // Singapore is a major financial hub
    Currency(code: 'SGD', name: 'Singapore Dollar', countryCode: 'SG'),
  ];
}

// ═══════════════════════════════════════════════════════════════════════════
// HOW THIS FILE CONNECTS TO THE REST OF THE APP
// ═══════════════════════════════════════════════════════════════════════════
//
//    CONVERTER SCREEN (converter_screen.dart):
//    ├─ Imports: import '../models/currency.dart';
//    ├─ Uses CurrencyData.currencies to populate dropdowns
//    ├─ Stores selected currencies in Currency objects
//    └─ Passes currency.code to API service for conversion
//
//    EXCHANGE ANALYSIS SCREEN (exchange_analysis_screen.dart):
//    ├─ Imports: import '../models/currency.dart';
//    ├─ Loops through CurrencyData.currencies to show rate cards
//    ├─ Uses currency.countryCode to display flags
//    └─ Uses currency.name for user-friendly display
//
//    CURRENCY SERVICE (currency_service.dart):
//    ├─ Doesn't import this file directly
//    ├─ Receives currency codes (String) from screens
//    └─ Uses codes to build API URLs (e.g., /latest/USD)
//
//    MAIN APP (main.dart):
//    └─ Doesn't use directly, but screens it creates do
//
// ═══════════════════════════════════════════════════════════════════════════
//   DATA FLOW EXAMPLE
// ═══════════════════════════════════════════════════════════════════════════
//
// User Action: Selects "Euro" in converter
//    ↓
// 1. Dropdown shows CurrencyData.currencies list
//    ↓
// 2. User clicks "EUR - Euro"
//    ↓
// 3. App stores: Currency(code: 'EUR', name: 'Euro', countryCode: 'EU')
//    ↓
// 4. Display shows: EU flag (using countryCode)
//    ↓
// 5. API call uses: currency.code = "EUR"
//    ↓
// 6. Service calls: api.com/latest/EUR
//    ↓
// 7. Result displayed in app
//
// ═══════════════════════════════════════════════════════════════════════════
//   KEY DART/FLUTTER CONCEPTS DEMONSTRATED
// ═══════════════════════════════════════════════════════════════════════════
//
//  Classes & Objects: Currency is a class, each currency is an object
//  Const Constructors: Efficient, compile-time constant objects
//  Final Properties: Immutable data (can't change after creation)
//  Named Parameters: Clear, readable function calls
//  Static Members: Class-level data, no instance needed
//  Generics (List<Currency>): Type-safe collections
//  Documentation Comments (///): In-code documentation
//  Data Modeling: Organizing related data into structures
//
// ═══════════════════════════════════════════════════════════════════════════
