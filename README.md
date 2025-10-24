# Currency Converter - Convertisseur de Devises

A modern Flutter currency converter application with real-time exchange rates and historical analysis.

## Features

- 🔄 Real-time currency conversion
- 📊 Historical exchange rate trends (7 days)
- 📈 Future rate projections
- 🌍 Support for 16 major world currencies
- 🎨 Dark theme with orange accents
- ⌨️ Custom number keyboard
- 📱 Material Design 3

## Quick Start

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                          # App entry point & navigation
├── models/
│   └── currency.dart                  # Currency data model
├── services/
│   └── currency_service.dart          # API service for exchange rates
└── screens/
    ├── converter_screen.dart          # Currency converter interface
    └── exchange_analysis_screen.dart  # Historical analysis & charts
```

### Key Files Explained

- **main.dart** - Launches the app, configures theme, sets up bottom navigation
- **currency.dart** - Defines Currency class and list of supported currencies
- **currency_service.dart** - Handles API calls to fetch exchange rates (current & historical)
- **converter_screen.dart** - Main conversion interface with custom keyboard
- **exchange_analysis_screen.dart** - Charts showing 7-day trends and future projections

## How It Works

### Currency Conversion Flow
1. User enters amount using custom keyboard
2. App calls exchange rate API
3. Conversion result displayed instantly
4. Exchange rate info shown below

### Historical Analysis
1. Fetches real 7-day historical data
2. Displays dual-curve chart:
   - Orange solid line: Historical rates
   - Orange dashed line: Future projection
3. Tap any currency card to update chart
4. Simple linear projection for next 2 days

## APIs Used

- **Current Rates**: exchangerate-api.com (free, no key needed)
- **Historical Data**: frankfurter.app (ECB data, free)

## Documentation

- 📖 [English Documentation](COMPREHENSIVE_DOCUMENTATION.md)
- 📖 [Documentation Française](DOCUMENTATION_COMPLETE_FR.md)

Detailed explanations of architecture, data flow, and Flutter concepts for beginners.

## Technologies

- Flutter 3.9+
- Dart 3.0+
- HTTP package for API calls
- FL Chart for graphs
- Country Flags for currency icons

## License

This project is open source and available for educational purposes.
