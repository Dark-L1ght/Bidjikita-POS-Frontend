# 🧾 Bidjikita POS — Cashier App

Flutter-based Point of Sale for **Bidjikita Coffee Roastery**. Works with an Express + Sequelize backend and a React admin dashboard.

## Project Structure

```
kasir_bidjikita/          ← Flutter cashier app (this repo)
bidjikita-POS-Backend/
├── api/                  ← Express + Sequelize REST API
│   ├── uploads/          ← Product & bundle images
│   └── src/
│       ├── controllers/
│       ├── models/
│       ├── routes/
│       └── middleware/
└── dashboard/            ← React admin dashboard (Vite + Tailwind)
```

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

## Screenshots

| Screen | Description |
|---|---|
| `LoginScreen` | Username + password |
| `PosDashboardScreen` | Main POS layout with catalog + cart panels |
| `CatalogPanel` | Product/bundle grid, search, category chips |
| `CartPanel` | Cart items, payment method selection, receipt |

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.44+ (Dart 3.11+) |
| State Mgmt | Riverpod (`flutter_riverpod`) |
| HTTP | `http` package |
| Navigation | `Navigator` (push-based dialogs) |
| PDF Receipt | `pdf` + `printing` packages |
| Fonts | Google Fonts (`Plus Jakarta Sans`) |
| Persistence | `shared_preferences` (auth token) |
| Icons | Material Design Icons |

## Getting Started

### 1. Backend

```bash
cd bidjikita-POS-Backend/api
cp .env.example .env   # edit database credentials
npm install
npm run dev            # starts on port 5000
```

### 2. Dashboard (optional)

```bash
cd bidjikita-POS-Backend/dashboard
npm install
npm run dev
```

### 3. Cashier App

```bash
cd kasir_bidjikita
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
flutter run -d windows   # or android / chrome / etc.
```

## App Architecture

```
lib/
├── config/
│   └── app_config.dart        ← Server URL
├── models/
│   ├── app_user.dart          ← User model
│   ├── bundle.dart            ← Bundle + BundleItem
│   ├── cart_item.dart         ← CartItem + BundleSubItem
│   ├── product.dart           ← Product model
│   ├── product_variant.dart   ← ProductVariant
│   └── receipt.dart           ← ReceiptData
├── providers/
│   ├── auth_provider.dart     ← Auth state (login/logout)
│   ├── cart_provider.dart     ← Cart state (items, totals)
│   ├── network_provider.dart  ← Connectivity check
│   └── product_provider.dart  ← Product + bundle list, filters
├── screens/
│   ├── login_screen.dart      ← Login page
│   └── pos_dashboard_screen.dart  ← Main POS layout
├── services/
│   ├── api_service.dart       ← HTTP calls (auth, products, orders, etc.)
│   └── receipt_printer.dart   ← PDF receipt generation
├── utils/
│   └── currency.dart          ← IDR formatting
└── widgets/
    ├── cart_panel.dart        ← Cart, payment dialogs, receipt
    └── catalog_panel.dart     ← Product grid, search, detail dialogs
```

## API Endpoints Used

| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/api/auth/login` | Login |
| GET | `/api/products` | Product list |
| GET | `/api/categories` | Category list |
| GET | `/api/bundles` | Active bundles |
| POST | `/api/orders` | Create order |
| POST | `/api/transactions` | Create transaction |

## Key Design Decisions

- **Bundles as Products** — Bundles from the API are converted into `Product` objects with `isBundle: true` for unified catalog rendering
- **Sub-items in cart** — When a bundle is added, it stays as one cart line item but stores expanded `BundleSubItem`s for order creation
- **On-screen keyboard** — Customer name uses a custom QWERTY keyboard inside the payment dialog, avoiding the OS keyboard on touchscreen POS terminals
- **Floating snackbar** — "Added to cart" toast is narrow (~360px) and left-aligned, sized dynamically via `MediaQuery`
- **Material 3** — Default purple seed is overridden with the brand dark green (`#04291A`)

## Build

```bash
flutter build apk --debug        # Android debug APK
flutter build apk --release      # Android release APK
flutter build windows            # Windows executable
flutter build linux              # Linux binary
flutter build macos              # macOS app
```
