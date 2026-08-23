# Revola Flutter Mobile Architecture & API Integration

This document outlines the architecture, state management patterns, and backend integration for the Revola Flutter Mobile Application.

---

## 📱 Mobile Architecture Overview

The Revola mobile app is built with **Flutter 3.x** and **Riverpod 2.6.x** targeting Android, iOS, and Web.

### Key Architecture Modules:
1. **State Management**: `flutter_riverpod` using `StateNotifierProvider` and `AsyncNotifierProvider` for reactive, testable UI binding.
2. **Routing & Deep Links**: `go_router` with declarative route trees and reactive auth redirection.
3. **Networking**: `dio` configured with interceptors for Bearer token injection and automatic 401 handling.
4. **Storage & Persistence**: `flutter_secure_storage` for JWT credentials and `shared_preferences` for user cache and theme preferences.
5. **Interactive Maps**: `flutter_map` with `latlong2` for geocoded Adama supply yard and depot visualization.
6. **Payments**: In-app Webview for Chapa Ethiopian payment gateway checkout with URL intercept callbacks.

---

## 🌐 Unified Backend API Integration

The mobile application connects directly to the unified Revola REST API:

- **Base URL Template**: `http://<SERVER_HOST>:5000/api/v1`
- **Authentication**: `POST /auth/login`, `POST /auth/register`, `POST /auth/google`, `GET /auth/me`
- **Catalog**: `GET /products`, `GET /products/:id`, `GET /products/map-locations`
- **Cart**: `GET /cart`, `POST /cart`, `PATCH /cart/:id`
- **Checkout & Orders**: `POST /orders/estimate-delivery-fee`, `POST /orders/checkout`, `GET /orders/my-orders`, `GET /orders/:id/track`
- **Notifications**: `GET /notifications`, `PATCH /notifications/read-all`

---

## 🌿 Team Workflow

- **Base Branches**: `main` (Production), `develop` (Staging).
- **Feature Branches**:
  - `feature/mobile-auth`
  - `feature/mobile-home`
  - `feature/mobile-marketplace`
  - `feature/mobile-cart`
  - `feature/mobile-checkout`
  - `feature/mobile-orders`
  - `feature/mobile-tracking`
  - `feature/mobile-profile`
