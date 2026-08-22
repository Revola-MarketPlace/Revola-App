# Revola Mobile Application 📱

> **"Every Good Thing Deserves a Second Life"**

Official mobile client for the **Revola** used & secondary materials marketplace platform. Built with Flutter, Dart, Riverpod, and Clean Architecture for Android and iOS.

---

## 🌟 Key Features

### 1. 🛍️ Buyer Experience
* **Discovery & Home:** Dynamic hero spotlight, category carousel, trust badges, and escrow guarantee banners.
* **Materials Catalog:** Real-time search, price range sliders, condition filters (*Like New, Good, Fair, Used*), and in-stock toggles.
* **Material Details:** Multi-image carousel, stock indicator, pricing in ETB, seller details, distance calculator, and Add-to-Cart.
* **Cart & Checkout:** Multi-seller cart management, Adama City geofenced delivery address picker, dynamic delivery fee estimation.
* **Payments:** In-app secure gateway for **Chapa**, **Telebirr**, and **Bank Transfer** (CBE / Awash receipt submission).
* **Order Management & Tracking:** Active orders list, detailed receipt breakdowns, dispute filing, and live OpenStreetMap delivery route tracking.
* **Saved Materials:** Favorites list cached locally and synced.

### 2. 🏪 Seller Portal
* **Seller Dashboard:** Metric cards for active listings, sales, and total earnings.
* **Listing Management:** Add, edit, and delete material listings with multi-photo picker/URLs, condition, category, and material type selection.
* **Order Fulfillment:** View buyer orders, status updates, and dispatch readiness.
* **Payouts:** Track pending, eligible, and completed payouts with automated commission deductions.

### 3. 🗺️ Interactive Marketplace Map
* **OpenStreetMap Integration:** Real-time map displaying approved marketplace sellers, admin-managed materials depots, and community recycling points across Adama City.
* **Interactive Callouts:** Tap any marker to view address, phone, and browse available inventory.

### 4. 🔔 Notifications & User Profile
* **Notification Center:** Real-time order updates, payment confirmations, and delivery alerts.
* **Profile Management:** Role switching (*Buyer / Seller*), profile updates, dispute resolution history, and escrow guidelines.

---

## 🏗️ Architecture & Tech Stack

```
lib/
├── core/
│   ├── config/          # Environment configuration (Dev / Prod URLs)
│   ├── constants/       # API endpoints, Adama GPS boundaries, Commission rate
│   ├── network/         # Dio HTTP client, JWT AuthInterceptor, Error handling
│   ├── storage/         # FlutterSecureStorage & SharedPreferences
│   ├── theme/           # Material 3 Theme (Royal Blue #2563EB & Orange #F97316)
│   ├── utils/           # Formatters (ETB, timestamps) & Haversine geofence helper
│   ├── providers/       # Global core Riverpod providers
│   └── router/          # Declarative GoRouter configuration with auth guards
├── features/
│   ├── auth/            # Login, Register, Splash, Onboarding, Role Selection
│   ├── home/            # Hero, Today's Pick, Categories, Trust Badges
│   ├── catalog/         # Search, Filter bottom sheet, Material grid
│   ├── material_details/# Gallery carousel, Seller info, Add to cart
│   ├── cart/            # Cart management, Quantity modifier, Subtotal
│   ├── checkout/        # Geofenced location picker, Dynamic fee calculator
│   ├── orders/          # Buyer orders, Details, Live tracking, Dispute form
│   ├── map/             # Interactive FlutterMap OSM with place markers
│   ├── seller/          # Seller metrics, Product CRUD, Orders, Payouts
│   ├── notifications/   # Notification center & unread badges
│   ├── profile/         # User profile, Favorites, Settings
│   └── shell/           # 5-tab Bottom Navigation Shell
└── shared/
    ├── models/          # User, Product, Category, MaterialType, Cart, Order, MapPlace
    └── widgets/         # BrandLogo, CustomButton, CustomTextField, MaterialCard
```

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK >= 3.41.9
* Dart SDK >= 3.11.5
* Android SDK (API 34+)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/petrossisay1646/App-revola.git
   cd App-revola
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   # Run on connected Android device or emulator
   flutter run

   # Or run on Chrome / Web
   flutter run -d chrome
   ```

4. Build release APK / App Bundle:
   ```bash
   flutter build apk --release
   flutter build appbundle
   ```

---

## 🔒 Security & Payment Safety
* Authentication tokens are stored securely in hardware-backed `FlutterSecureStorage`.
* Payments are verified server-side against backend webhooks and Chapa APIs.
* Escrow protection prevents payout release until delivery is confirmed.