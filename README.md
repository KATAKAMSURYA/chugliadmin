<div align="center">
  <h1>🛡️ ChugLi Admin Panel</h1>
  <p><strong>The central command center for managing the ChugLi ecosystem.</strong></p>

  [![Flutter Version](https://img.shields.io/badge/Flutter-%5E3.12.2-02569B?logo=flutter)](https://flutter.dev/)
  [![Firebase](https://img.shields.io/badge/Firebase-Integrated-FFCA28?logo=firebase)](https://firebase.google.com/)
  [![Dart](https://img.shields.io/badge/Dart-%5E3.0.0-0175C2?logo=dart)](https://dart.dev/)
</div>

---

## 📖 About ChugLi Admin

**ChugLi Admin** is the internal management application built to moderate, analyze, and control the **ChugLi** hyper-local anonymous chat platform. Designed for administrators and moderators, this dashboard provides a comprehensive overview of platform activity, user reports, and system health.

Built with a responsive, modern Flutter interface and powered by Firebase, this panel allows for real-time moderation and data-driven decision-making.

## ✨ Key Features

*   📊 **Analytics Dashboard:** Real-time metrics on active rooms, user engagement, and system activity using beautiful interactive charts (`fl_chart`).
*   🛡️ **Live Chat Moderation:** Monitor active and high-activity rooms. Intervene, delete messages, or shut down rooms that violate community guidelines.
*   🚨 **Report Management:** Review and resolve user-submitted reports. Automatically enforce bans or warnings based on community flags.
*   👥 **User Management:** Oversee anonymous user sessions, track behavioral patterns, and manage bans across the platform.
*   ⚙️ **System Settings:** Dynamically configure app-wide parameters like default radius limits, expiry times, and category visibility.
*   🔐 **Secure Authentication:** Administrator-only access guarded by Firebase Authentication and custom claims.

## 🛠️ Tech Stack

### Core
*   [Flutter](https://flutter.dev/) (UI Toolkit, optimized for Web and Desktop)
*   [Dart](https://dart.dev/) (Language)
*   **Riverpod** (`flutter_riverpod`): Robust, scalable state management.
*   **GoRouter** (`go_router`): Declarative URL-based routing.

### Backend & Infrastructure
*   **Firebase Authentication:** Secure admin login.
*   **Cloud Firestore:** Real-time NoSQL database management.
*   **Firebase Cloud Functions:** Triggered via admin actions (e.g., executing bans, sending system-wide broadcasts).

### UI / UX
*   `fl_chart`: Rich data visualization.
*   `google_fonts`: Modern typography (Inter, Roboto, etc.).
*   `cupertino_icons`: Clean iconography.

## 🚀 Getting Started

### Prerequisites

*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.12.2 or higher)
*   [Firebase CLI](https://firebase.google.com/docs/cli)
*   Access to the primary ChugLi Firebase Project.

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/KATAKAMSURYA/chugliadmin.git
    cd chugli_admin
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Configure Firebase**
    Run the FlutterFire CLI to link the app to your Firebase environment:
    ```bash
    flutterfire configure
    ```
    *(Ensure you are linking this to the same Firebase project as the main ChugLi app).*

4.  **Run the app**
    ```bash
    flutter run -d chrome
    # Or run on macOS/Windows desktop for the best admin experience
    ```

## 📂 Project Structure

This project follows a feature-first architectural pattern:

```text
lib/
├── core/
│   ├── providers/     # Global Riverpod providers (Firebase instances)
│   ├── routing/       # GoRouter configuration (app_router.dart)
│   └── theme/         # Admin panel styling and color palettes
├── features/
│   ├── analytics/     # Traffic, engagement, and system health charts
│   ├── auth/          # Admin login and session management
│   ├── dashboard/     # High-level overview and quick stats
│   ├── moderation/    # Live chat monitoring and intervention
│   ├── reports/       # Ticketing system for user flags
│   ├── rooms/         # Active room management
│   ├── settings/      # App-wide remote config and parameters
│   ├── shell/         # Main navigation scaffold (Sidebar/Appbar)
│   └── users/         # User behavior tracking and bans
├── main.dart          # Application entry point
└── firebase_options.dart # Auto-generated Firebase config
```

## 🔐 Security & Access Control

*   **Role-Based Access:** This application is strictly for authorized personnel. Firebase Security Rules must be configured to only allow reads/writes from users with a specific `admin` custom claim.
*   **Audit Logging:** Every action taken within the admin panel (deleting a room, banning a user) should be logged for accountability.

## 🤝 Contributing

This is a restricted administrative repository. If you are part of the core team:

1. Create a feature branch (`git checkout -b feat/new-moderation-tool`).
2. Commit your changes (`git commit -m 'Add new moderation tool'`).
3. Push to the branch (`git push origin feat/new-moderation-tool`).
4. Open a Pull Request for code review.

## 📄 License

This project is proprietary and confidential. Unauthorized copying of this file, via any medium, is strictly prohibited.
