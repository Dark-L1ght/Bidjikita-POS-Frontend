# 🧾 Bidjikita POS — Cashier App

Flutter-based Point of Sale for **Bidjikita Coffee Roastery**.

## Features

- **Catalog** — Grid of products and bundles with search & category filters
- **Cart** — Add items, variants, notes, bundle expansion into sub-items
- **Bundles** — Combo deals with auto-calculated cost/profit, optional upload image
- **Payment** — QRIS or cash with custom numpad
- **Receipt** — In-app preview + ESC/POS thermal printer support (PDF)
- **Customer name** — Optional on-screen keyboard input before payment
- **Orders** — Sent to backend as single line-items (bundles expanded)
- **Network detection** — Wi-Fi indicator in AppBar
- **Auth** — JWT-based login with persistent session

## Screens

| Screen | Description |
|---|---|
| `LoginScreen` | Username + password login |
| `PosDashboardScreen` | Main POS layout with catalog + cart panels |
| `CatalogPanel` | Product/bundle grid, search, category chips |
| `CartPanel` | Cart items, payment method selection, receipt |

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.44+ (Dart 3.11+) |
| State Management | Riverpod (`flutter_riverpod`) |
| HTTP | `http` package |
| PDF Receipt | `pdf` + `printing` packages |
| Fonts | Google Fonts (`Plus Jakarta Sans`) |
| Persistence | `shared_preferences` (auth token) |

## Getting Started

```bash
flutter pub get
```

Configure the server URL in `lib/config/app_config.dart`:

| Platform | `baseUrl` |
|---|---|
| Android Emulator | `http://10.0.2.2:5000` |
| iOS Simulator | `http://localhost:5000` |
| Windows / Linux / macOS | `http://localhost:5000` |
| Physical device | `http://YOUR_MACHINE_IP:5000` |

Run:

```bash
flutter run -d windows   # or android / ios / chrome / etc.
```

## App Structure

```
lib/
├── config/
│   └── app_config.dart         ← Server base URL
├── models/
│   ├── app_user.dart           ← User model
│   ├── bundle.dart             ← Bundle + BundleItem
│   ├── cart_item.dart          ← CartItem + BundleSubItem
│   ├── product.dart            ← Product model
│   ├── product_variant.dart    ← ProductVariant
│   └── receipt.dart            ← ReceiptData
├── providers/
│   ├── auth_provider.dart      ← Auth state (login/logout)
│   ├── cart_provider.dart      ← Cart state (items, totals)
│   ├── network_provider.dart   ← Connectivity check
│   └── product_provider.dart   ← Product + bundle list, filters
├── screens/
│   ├── login_screen.dart       ← Login page
│   └── pos_dashboard_screen.dart   ← Main POS layout
├── services/
│   ├── api_service.dart        ← HTTP calls
│   └── receipt_printer.dart    ← PDF receipt generation
├── utils/
│   └── currency.dart           ← IDR formatting
└── widgets/
    ├── cart_panel.dart         ← Cart, payment dialogs, receipt
    └── catalog_panel.dart      ← Product grid, search, detail dialogs
```

## Configuration

### `lib/config/app_config.dart`

```dart
static const String baseUrl = 'http://10.0.2.2:5000';
```

Change this to match your server address.

## Build

```bash
flutter build apk --debug        # Android debug APK
flutter build apk --release      # Android release APK
flutter build windows            # Windows executable
flutter build linux              # Linux binary
flutter build macos              # macOS app
```
