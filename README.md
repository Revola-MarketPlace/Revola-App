# Revola Mobile — Flutter Cross-Platform Application

Welcome to the official **Revola Flutter Mobile Application** team repository.

Revola is a managed marketplace for reclaimed and circular construction materials in Adama, Ethiopia. This repository contains the Flutter cross-platform mobile application codebase for Android, iOS, and Web.

---

## 🏗️ Architecture Overview

The mobile application follows a Feature-First modular architecture using **Flutter Riverpod (2.6.x)** for state management and **GoRouter** for routing:

```text
lib/
├── core/                # Global configs, theme, network (Dio), storage, router, utils
├── features/            # Isolated domain feature packages (auth, catalog, cart, checkout, orders, map, etc.)
└── shared/              # Shared data models and reusable UI widgets
```

---

## 🚀 Getting Started

### 1. Prerequisites
- **Flutter SDK**: `>=3.29.0` / Dart `^3.11.5`
- **Android Studio / VS Code** with Flutter & Dart extensions
- **Revola Backend**: Running locally (`http://10.0.2.2:5000/api/v1` on Android Emulator or LAN IP on real device)

### 2. Setup & Run
```bash
flutter pub get
flutter run
```

---

## 🔒 Security & Environment
- Never commit private signing keys (`*.jks`, `key.properties`, `local.properties`).
- The mobile app connects to the unified Revola Backend API (`/api/v1`).
