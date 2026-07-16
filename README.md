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
- **Shift** — Clock-in/clock-out per cashier with starting cash, expected cash/QRIS reconciliation, and live shift summary dashboard
- **Printer settings** — Configure Bluetooth or network (Wi-Fi/LAN) ESC/POS printer and paper size (58mm/80mm)

## Screens

| Screen | Description |
|---|---|
| `SplashScreen` | Checks for an active shift after login and routes accordingly |
| `LoginScreen` | Username + password login |
| `ClockInScreen` | Start a new shift with starting cash before reaching the POS |
| `PosDashboardScreen` | Main POS layout with catalog + cart panels, plus shift dashboard tab |
| `SettingsScreen` | Configure Bluetooth/network thermal printer and paper size |
| `CatalogPanel` | Product/bundle grid, search, category chips |
| `CartPanel` | Cart items, payment method selection, receipt |
| `ShiftDashboard` | Shift summary widget — expected cash/QRIS, order count, end-shift action |

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
│   ├── receipt.dart            ← ReceiptData
│   └── shift.dart              ← Shift model (cashier shift tracking)
├── providers/
│   ├── auth_provider.dart      ← Auth state (login/logout)
│   ├── cart_provider.dart      ← Cart state (items, totals)
│   ├── network_provider.dart   ← Connectivity check
│   ├── product_provider.dart   ← Product + bundle list, filters
│   └── shift_provider.dart     ← Active shift state (clock-in/clock-out)
├── screens/
│   ├── splash_screen.dart      ← Routes based on active shift
│   ├── login_screen.dart       ← Login page
│   ├── clock_in_screen.dart    ← Start shift with starting cash
│   ├── pos_dashboard_screen.dart   ← Main POS layout
│   └── settings_screen.dart    ← Thermal printer configuration
├── services/
│   ├── api_service.dart        ← HTTP calls
│   ├── receipt_printer.dart    ← PDF receipt generation
│   └── thermal_printer.dart    ← Bluetooth/network ESC/POS printing
├── utils/
│   └── currency.dart           ← IDR formatting
└── widgets/
    ├── cart_panel.dart         ← Cart, payment dialogs, receipt
    ├── catalog_panel.dart      ← Product grid, search, detail dialogs
    └── shift_dashboard.dart    ← Shift summary tab (cash/QRIS reconciliation)
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
