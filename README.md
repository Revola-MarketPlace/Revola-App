# 📱 Revola — Flutter Cross-Platform Mobile Application

[![Flutter](https://img.shields.io/badge/Flutter-3.29%2B-02569B?style=flat-square&logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.11%2B-0175C2?style=flat-square&logo=dart)](https://dart.dev/)
[![Riverpod](https://img.shields.io/badge/State_Management-Riverpod_2.6-blueviolet?style=flat-square)](https://riverpod.dev/)
[![Platform](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web-brightgreen?style=flat-square)](#)
[![License](https://img.shields.io/badge/License-Proprietary-red?style=flat-square)](#)

> **Revola Mobile** is the companion cross-platform mobile application for the Revola Reclaimed Materials Marketplace, engineered with Flutter and Dart for Android, iOS, and Web. It delivers a native, responsive experience for construction buyers, material sellers, and depot staff in Adama, Ethiopia.

---

## 📑 Table of Contents

- [Features Overview](#-features-overview)
- [Architecture & State Management](#-architecture--state-management)
- [Repository Structure](#-repository-structure)
- [Technology Stack & Packages](#-technology-stack--packages)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation & Setup](#installation--setup)
  - [Connecting to the Backend](#connecting-to-the-backend)
- [Building & Testing](#-building--testing)
  - [Running Unit & Widget Tests](#running-unit--widget-tests)
  - [Building Android Release APK](#building-android-release-apk)
  - [Building Flutter Web](#building-flutter-web)
- [Key Flows Implemented](#-key-flows-implemented)
- [Security & Storage](#-security--storage)
- [Team Git Workflow](#-team-git-workflow)

---

## 🌟 Features Overview

- 🔑 **Complete Authentication Suite**:
  - Email/Username + Password sign-in and registration with instant validation.
  - Native **Google Sign-In** linked seamlessly to the unified Revola backend account.
  - Persistent login across app restarts via `FlutterSecureStorage` and `SharedPreferences`.
  - Profile avatar upload with direct backend caching and instant image cache busting (`?t=timestamp`).
- 🛒 **Buyer Marketplace & Shopping**:
  - Live salvaged materials catalog with search, price sorting, and category filters (Metals, Wood, Masonry, Plastics).
  - Isolated shopping cart with live stock limit checks and quantity adjustment.
  - Interactive **Adama Marketplace Map** powered by OpenStreetMap & `flutter_map` displaying 30+ verified supply yards and depots.
- 💳 **Integrated Checkout & Payments**:
  - Real-time dynamic delivery fee estimation based on Adama geographic coordinates.
  - In-app **Chapa Ethiopian Payment Gateway** webview with callback interception.
  - Manual CBE Bank Transfer receipt upload.
- 📦 **Order Management & Live Tracking**:
  - Detailed order tracking screen with sequential milestone progress bar (`Order Placed` → `Confirmed` → `Hub Dispatch` → `Out for Delivery` → `Delivered`).
  - Dispute filing with photo attachment support.
- 🏪 **Seller Management Portal**:
  - Create and edit reclaimed material listings with multiple image upload and condition grading.
  - Seller dashboard displaying inventory count, active sales, and payout eligibility.
- 🌓 **Appearance Mode Switcher**:
  - Dark, Light, and System Theme support with persistent preference storage.

---

## 🏛️ Architecture & State Management

The application strictly adheres to a **Feature-First modular architecture** coupled with **Flutter Riverpod (2.6.x)** for clean separation of concerns:

```text
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                     │
│   ConsumerWidgets, Screens, BottomSheets, Modal Dialogs     │
└──────────────────────────────┬──────────────────────────────┘
                               │ State Listening & UI Events
┌──────────────────────────────▼──────────────────────────────┐
│                      CONTROLLERS / LOGIC                    │
│   Riverpod StateNotifier / AsyncNotifier Providers          │
│   (e.g., AuthController, CartController, OrderController)   │
└──────────────────────────────┬──────────────────────────────┘
                               │ Data Calls
┌──────────────────────────────▼──────────────────────────────┐
│                      REPOSITORIES / DATA                    │
│   Dio HTTP Client with JWT Auth Interceptors & Storage API  │
└──────────────────────────────┬──────────────────────────────┘
                               │ HTTPS / JSON REST API
┌──────────────────────────────▼──────────────────────────────┐
│                     REVOLA BACKEND API                      │
│   Unified REST API (`http://<SERVER_HOST>:5000/api/v1`)     │
└─────────────────────────────────────────────────────────────┘
```

---

## 📂 Repository Structure

```text
App-revola/
├── android/                    # Native Android project configuration & Gradle scripts
├── ios/                        # Native iOS project configuration & CocoaPods
├── web/                        # Flutter Web support files and manifest
├── assets/                     # Application icons, images, and brand assets
│   ├── icons/
│   └── images/
├── test/                       # Unit and widget test suite
├── lib/
│   ├── main.dart               # App entry point with ProviderScope
│   ├── core/                   # Shared infrastructure
│   │   ├── config/             # Environment & API Base URL constants
│   │   ├── constants/          # Colors, typography, spacing, and dimensions
│   │   ├── network/            # Dio client instance & Auth interceptor
│   │   ├── providers/          # Global Riverpod providers
│   │   ├── router/             # GoRouter configuration & auth redirect guards
│   │   ├── storage/            # Secure storage service (JWT, user cache, theme)
│   │   ├── theme/              # Light & Dark theme definitions
│   │   └── utils/              # Currency, date, and dialog helpers
│   ├── features/               # Feature-first domain modules
│   │   ├── admin/              # Staff & admin dashboard screens
│   │   ├── auth/               # Login, Register, Google Sign-In, OTP
│   │   ├── cart/               # Cart screen, quantity controllers
│   │   ├── catalog/            # Materials catalog, filter bottom sheets
│   │   ├── checkout/           # Checkout, payment webview, order success
│   │   ├── home/               # Home screen, category cards, promotions
│   │   ├── map/                # OpenStreetMap depot and seller visualizer
│   │   ├── material_details/   # Material page, image carousel, specs
│   │   ├── notifications/      # Notification list, mark-read controller
│   │   ├── orders/             # Order list, details, live tracking, dispute
│   │   ├── profile/            # Profile screen, avatar upload, appearance
│   │   ├── seller/             # Seller dashboard, add/edit material form
│   │   └── shell/              # Bottom navigation bar shell
│   └── shared/                 # Shared domain models and widgets
│       ├── models/             # UserModel, ProductModel, CartModel, OrderModel
│       └── widgets/            # CustomButton, CustomTextField, MaterialCard
├── pubspec.yaml                # Flutter dependencies and asset declarations
├── analysis_options.yaml       # Dart analysis and linting rules
└── README.md
```

---

## 💻 Technology Stack & Packages

| Category | Package | Purpose |
|---|---|---|
| **State Management** | `flutter_riverpod: ^2.6.1` | Reactive, compile-safe dependency injection and state |
| **Navigation** | `go_router: ^17.5.0` | Declarative routing with deep links and auth redirects |
| **Networking** | `dio: ^5.11.0` | HTTP client with request/response interceptors |
| **Secure Storage** | `flutter_secure_storage: ^11.0.0` | Encrypted storage for JWT session tokens |
| **Preferences** | `shared_preferences: ^2.5.5` | Local storage for appearance mode and user cache |
| **Maps & GIS** | `flutter_map: ^8.3.1`, `latlong2` | OpenStreetMap renderer with Adama custom depot markers |
| **Payments** | `webview_flutter: ^4.14.1` | In-app secure browser for Chapa checkout completion |
| **Media / Photos** | `image_picker: ^1.2.3` | Camera and gallery picker for receipts and avatars |
| **Google Sign-In** | `google_sign_in: ^6.2.1` | Official Google OAuth client for Android and iOS |
| **Images Cache** | `cached_network_image: ^3.4.1` | Performant image caching with error placeholders |

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: `>= 3.29.0`
- **Dart SDK**: `>= 3.11.5`
- **Android Studio / Xcode** with Android SDK 34 / iOS 15+ support.
- **Revola Backend Server**: Running locally or on a LAN/cloud server.

---

### Installation & Setup

1. Clone or extract the mobile project:
   ```bash
   cd App-revola
   ```
2. Fetch Flutter packages:
   ```bash
   flutter pub get
   ```
3. Check environment readiness:
   ```bash
   flutter doctor
   ```

---

### Connecting to the Backend

In `lib/core/config/app_config.dart`, configure your backend host:
- **Android Emulator**: `http://10.0.2.2:5000/api/v1`
- **Physical Android Device (LAN)**: `http://192.168.x.x:5000/api/v1`
- **Production Backend**: `https://adamamaterials-e-commerce.onrender.com/api/v1`

Run the application:
```bash
flutter run
```

---

## 🛠️ Building & Testing

### Running Unit & Widget Tests
```bash
flutter test
```

### Building Android Release APK
```bash
flutter build apk --release
```
*Output APK located at:* `build/app/outputs/flutter-apk/app-release.apk`

### Building Flutter Web
```bash
flutter build web --release
```
*Output Web build located at:* `build/web/`

---

## 🔒 Security & Storage

- **Encrypted Token Vault**: All JWT credentials are encrypted using Android Keystore / iOS Keychain via `flutter_secure_storage`.
- **Zero Hardcoded Secrets**: No API secret keys, Google client secrets, or Chapa secrets are bundled in the mobile binary. All payment charges and credential exchanges occur exclusively server-side.
- **Automatic Session Invalidation**: 401 Unauthorized responses trigger automatic cache clearing and redirect the user back to the login screen.

---

## 🌿 Team Git Workflow

- `main` — Production release branch.
- `develop` — Main mobile integration branch.
- Feature branches:
  - `feature/mobile-auth`
  - `feature/mobile-marketplace`
  - `feature/mobile-cart`
  - `feature/mobile-checkout`
  - `feature/mobile-orders`
  - `feature/mobile-profile`
