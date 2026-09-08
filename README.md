# EduGovernance ERP - School Management System

Enterprise-grade School Management System built with **Flutter**, **BLoC**, and **GoRouter**, featuring strict **Role-Based Access Control (RBAC)** across three primary user roles:
- 🏛️ **School Manager (`ADMIN`)**: Academic master data, staff directory, payroll, audit logs, fee structure engine, defaulters, and examination publication gates. Includes session inactivity protection (15-min timeout).
- 👩‍🏫 **Teacher & Staff (`TEACHER`)**: One-tap attendance roll call, attendance correction window, homework publisher, submission reviewer, and exam marks grid.
- 👨‍👩‍👧 **Parent & Guardian (`PARENT`)**: Visual attendance calendar, instant absence alerts, digital leave requests, fee ledger with UPI payments, structured homework feed, and digitally signed PDF report cards.

---

## Architecture Highlights
* **Architecture Pattern**: Feature-First Architecture (`core/`, `features/auth/`, `features/attendance/`, `features/fees/`, `features/homework/`, `features/exams/`, `features/*_portal/`).
* **State Management**: `flutter_bloc` with decoupled events and states.
* **Declarative Routing**: `go_router` with reactive `refreshListenable` bound to `AuthBloc` state stream.
* **RBAC Redirect Guards**: Automatically prevents unauthenticated access and anti-privilege escalation (e.g. Parents or Teachers accessing `/admin` are bounced to their assigned portal).
* **Storage & Security**: `flutter_secure_storage` for token, role, and profile persistence.
* **Session Integrity**: `SessionManager` monitors activity and enforces role-tailored timeouts.

---

## Automated Testing
Run the complete automated test suite:
```bash
flutter test
```
Tests include:
- `test/router_redirect_test.dart`: Complete GoRouter RBAC redirect guard matrix.
- `test/auth_bloc_test.dart`: BLoC state transitions (AppStarted, LoginSubmitted, SessionTimedOut, LogoutRequested).
- `test/session_manager_test.dart`: Inactivity policies and role timeout mathematics.

---

## Automated Android APK Generation
This repository includes a GitHub Actions workflow in `.github/workflows/build_apk.yml`.
Whenever you push to `main` or trigger manual dispatch in the **Actions** tab, it automatically compiles a release Android APK and uploads it as a downloadable artifact.
