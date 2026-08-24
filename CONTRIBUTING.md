# Contributing to Revola Mobile

Please follow these guidelines when contributing to the mobile application.

---

## 🌿 Git Branching Workflow

1. **Base Branches**:
   - `main` — Production-ready release branch.
   - `develop` — Integration branch for active mobile sprints.

2. **Feature Branch Convention**:
   - `feature/mobile-auth`
   - `feature/mobile-home`
   - `feature/mobile-marketplace`
   - `feature/mobile-cart`
   - `feature/mobile-checkout`
   - `feature/mobile-orders`
   - `feature/mobile-tracking`
   - `feature/mobile-profile`

3. **Pull Request Requirements**:
   - Target `develop` branch.
   - Run `flutter analyze` and `flutter test` before submitting PRs.
   - No hardcoded tokens, passwords, or keystore files.
