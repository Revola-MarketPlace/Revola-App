# Revola Flutter Architecture

This document describes the structure and state management conventions for Revola Mobile.

---

## 🏛️ Application Architecture

```text
┌─────────────────────────────────────────────────────────────┐
│                       Presentation Layer                    │
│  Flutter Screens, ConsumerWidgets, BottomSheets & Dialogs   │
└──────────────────────────────┬──────────────────────────────┘
                               │ State / Events (Riverpod)
┌──────────────────────────────▼──────────────────────────────┐
│                        Domain / Logic                       │
│  StateNotifier / AutoDisposeAsyncNotifier Controllers       │
└──────────────────────────────┬──────────────────────────────┘
                               │ Repositories & Data Calls
┌──────────────────────────────▼──────────────────────────────┐
│                         Data Layer                          │
│  Dio HTTP Client, FlutterSecureStorage, SharedPreferences    │
└──────────────────────────────┬──────────────────────────────┘
                               │ HTTPS / JSON REST API
┌──────────────────────────────▼──────────────────────────────┐
│                    Revola Backend API                       │
│  Express.js REST Services (`/api/v1`)                       │
└─────────────────────────────────────────────────────────────┘
```
