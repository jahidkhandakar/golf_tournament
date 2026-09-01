# Golf Game Play

A comprehensive golf tournament and social networking mobile application that enables golfers to find, create, and manage golf tournaments, connect with other players, participate in challenges, and communicate via real-time messaging.

## 📱 App Idea & Core Concept

**Golf Game Play** bridges the gap between golf enthusiasts by providing a unified platform for tournament management, player matchmaking, and social interaction. Whether you're looking to join a club tournament, organize a casual outing, challenge another player, or simply connect with fellow golfers in your area, this app delivers a complete social-golfing experience.

## ✨ Key Features

### 🏆 Tournament Management
- **Club Tournaments** — Create and manage large-scale club tournaments
- **Small Outings** — Organize casual games with friends
- **Tee Sheet Management** — Assign players to groups and manage tee times
- **Invitations System** — Send, accept, or reject tournament invitations
- **Looking To Play** — Matchmaking system for golfers seeking games
- **Request To Play** — Join existing games and tournaments

### ⚔️ Challenges & Matches
- Create head-to-head challenge matches
- Track match history and results
- Manage active and completed challenges

### 🏅 Scoring & Winners
- Record scores, skins, KPS (Keenest Putts per Stroke), and top winners
- Edit and manage winner details
- Track completed games and leaderboards
- Top 50 golfers leaderboard

### 💬 Real-Time Messaging
- Individual and group chats via Socket.IO
- Chat history and message inbox
- Live message notifications

### 🤝 Social Features
- Friend requests and friend lists
- User profiles with social links (Facebook, Instagram, LinkedIn, X/Twitter)
- Groups creation and management
- Posts and activity feed

### 📍 Location Services
- GPS-based current location detection
- Location-based tournament filtering (city, state, country)
- Google Maps integration for golf courses
- Places autocomplete and geocoding

### 👤 User Management
- Sign up / Sign in with JWT authentication
- OTP and email verification
- Password reset flow
- Profile customization (avatar, cover image, handicap, personal details)
- Role-based access control (users vs admins)

### 💰 Sponsorship & Subscriptions
- Sponsor content carousel on home screen
- Sponsor signup and management
- Subscription packages and payment integration

### 🌐 Additional Features
- Notifications system
- PDF generation and printing (scorecards/receipts)
- Multi-language support (English, Arabic, Spanish)
- RTL layout support for Arabic
- Settings (Privacy Policy, Terms & Conditions, About Us, Support)
- Contact Us functionality

## 🏗️ Architecture

The app follows an **MVC (Model-View-Controller)** architecture powered by **GetX** for state management and dependency injection.

```
┌─────────────────────────────────────────────┐
│                   View Layer                │
│  (GetBuilder / Obx Widgets / UI Screens)    │
├─────────────────────────────────────────────┤
│               Controller Layer              │
│  (GetxController / Business Logic / API)    │
├─────────────────────────────────────────────┤
│                 Model Layer                 │
│  (Data Models / JSON Serialization)         │
├─────────────────────────────────────────────┤
│               Data Layer                    │
│  (API Services / SharedPreferences / IO)    │
└─────────────────────────────────────────────┘
```

### Architecture Highlights
- **Feature-based modular structure** — Each module has its own Binding, Controller, and View
- **Reactive state management** — `.obs` observables and `Obx` widgets
- **Lazy dependency injection** — `Get.lazyPut` for efficient resource loading
- **Manual JSON serialization** — No code generation, lightweight and transparent
- **Pagination support** — Built-in page, limit, and totalPages tracking

## 🛠️ Tech Stack

| Category | Technology |
|---|---|
| **Framework** | Flutter (Dart SDK ^3.5.4) |
| **State Management** | GetX ^4.6.6 |
| **HTTP Client** | `http` package |
| **Real-Time** | Socket.IO Client |
| **Local Storage** | SharedPreferences, GetStorage |
| **Maps** | Google Maps Flutter, Geolocator, Geocoding |
| **UI/Widgets** | Flutter Spinkit, Lottie, Shimmer, Carousel Slider, Pin Code Fields |
| **Media** | Image Picker, File Picker, Cached Network Image, Flutter SVG |
| **Utilities** | JWT Decoder, Dartz, Intl, MIME, Permission Handler, URL Launcher |
| **PDF/Share** | PDF, Printing, Share Plus |
| **Localization** | GetX Translations (EN, AR, ES) |
| **Screen Utils** | Flutter ScreenUtil (393x852 design base) |
| **Fonts** | Google Fonts, Custom (Schuyler, DMSans) |

### Minimum Requirements
- **Android SDK:** 21 (Android 5.0 Lollipop)
- **Dart SDK:** ^3.5.4

## 📂 Project Structure

```
golf_app/
├── lib/
│   ├── main.dart                        # App entry point
│   ├── app/
│   │   ├── data/
│   │   │   ├── api_constants.dart       # 80+ API endpoint definitions
│   │   │   └── google_api_service.dart  # Google Places/Geocoding helper
│   │   ├── routes/
│   │   │   ├── app_pages.dart           # Route definitions (50+ routes)
│   │   │   └── app_routes.dart          # Route path constants
│   │   └── modules/                     # Feature modules (41 modules)
│   │       ├── auth/                    # Authentication (login, signup, OTP)
│   │       ├── home/                    # Home screen & dashboard
│   │       ├── bottom_menu/             # Bottom navigation bar
│   │       ├── tournament/              # Tournament CRUD operations
│   │       ├── invitation/              # Invitation management
│   │       ├── challenge/               # Challenge matches
│   │       ├── winner/                  # Scoring & winners
│   │       ├── message_inbox/           # Real-time messaging
│   │       ├── profile/                 # User profile management
│   │       ├── groups/                  # Groups management
│   │       ├── friend/                  # Friends system
│   │       ├── looking_to_play/         # Player matchmaking
│   │       ├── sponsor/                 # Sponsorship features
│   │       ├── subscription/            # Subscription packages
│   │       ├── notification/            # Push notifications
│   │       ├── settings/                # App settings
│   │       └── model/                   # Shared data models
│   └── common/
│       ├── controller/                  # Global controllers (Theme, Locale)
│       ├── di/                          # Dependency injection setup
│       ├── prefs_helper/                # SharedPreferences wrapper
│       ├── widgets/                     # 33+ reusable widgets
│       ├── themes/                      # Material theme definitions
│       ├── app_color/                   # Color constants (Primary: #F1BD19)
│       ├── app_icons/                   # Icon path constants
│       ├── app_images/                  # Image path constants
│       ├── app_text_style/              # Typography constants
│       ├── app_string/                  # String constants
│       ├── helper/                      # Utility helpers
│       └── app_drawer/                  # Side drawer navigation
├── assets/
│   ├── language/                        # Localization files (en, ar, es)
│   ├── icons/                           # SVG/PNG icons (56 files)
│   ├── image/                           # Static images
│   └── lotti/                           # Lottie animations
├── test/                                # Unit & widget tests
├── pubspec.yaml                         # Project dependencies
└── README.md
```

## 🚀 Installation & Run Guide

### Prerequisites
- Flutter SDK (>=3.5.4)
- Dart SDK (>=3.5.4)
- Android Studio / VS Code with Flutter extensions
- An Android/iOS device or emulator

### Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd golf_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Endpoints**
   
   Update the base URLs in `lib/app/data/api_constants.dart`:
   ```dart
   static const String baseUrl = 'YOUR_BACKEND_URL/v1';
   static const String imageBaseUrl = 'YOUR_BACKEND_URL';
   static const String socketUrl = 'YOUR_BACKEND_URL';
   ```

4. **Configure Google Maps API Key**
   
   Update the API key in `lib/app/data/google_api_service.dart`:
   ```dart
   static const String apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
   ```

5. **Run the app**
   ```bash
   # For Android
   flutter run

   # For iOS
   flutter run -d ios

   # For a specific device
   flutter devices
   flutter run -d <device-id>
   ```

6. **Build Release APK**
   ```bash
   flutter build apk --release
   ```

## 🎮 Usage

### Getting Started
1. **Sign Up** — Create an account with email/phone verification
2. **Complete Profile** — Add your handicap, profile picture, and social links
3. **Explore Tournaments** — Browse tournaments near your location
4. **Join or Create** — Join existing tournaments or create your own
5. **Connect** — Add friends, join groups, and start chatting

### Core Workflows

**Creating a Tournament:**
- Navigate to the Tournament tab
- Tap "Create Tournament" (admin role required)
- Fill in tournament details, location, and date
- Invite players or make it public

**Finding a Game:**
- Use "Looking To Play" to find available games
- Filter by location, date, or skill level
- Send a request to join or create your own

**Messaging:**
- Access the Messages tab for your inbox
- Start individual or group chats
- Receive real-time notifications via Socket.IO

## 🔮 Future Improvements

- [ ] **Firebase Integration** — Push notifications and analytics
- [ ] **Payment Gateway** — Stripe/PayPal for tournament fees and subscriptions
- [ ] **Live Score Tracking** — Real-time score updates during tournaments
- [ ] **Handicap System** — Automated handicap calculation and updates
- [ ] **Weather Integration** — Golf course weather forecasts
- [ ] **Course Reviews** — Rate and review golf courses
- [ ] **Event Calendar** — Integrated calendar for tournaments and events
- [ ] **Video Highlights** — Share tournament video highlights
- [ ] **Advanced Analytics** — Player statistics and performance tracking
- [ ] **Offline Mode** — Cache data for offline access
- [ ] **Dark Theme** — Complete dark mode support
- [ ] **Unit & Widget Tests** — Expand test coverage

## 🤝 Contribution

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Guidelines
- Follow the existing GetX MVC architecture pattern
- Maintain consistent code style (`flutter analyze` should pass)
- Add comments for complex logic
- Test your changes on both Android and iOS
- Update documentation if necessary

## 📄 License

This project is proprietary software. All rights reserved.

Unauthorized copying, modification, distribution, or use of this software via any medium is strictly prohibited without prior written permission from the author(s).

## 👤 Author

**Golf Game Play** is developed and maintained by the Golf Game Play team.

- **Application ID:** `com.golfgameplay.golfgame`
- **Version:** 1.0.0+1
- **Built With:** Flutter & Dart

---

## Product naming

The app is branded **GGW Connect**. The repo and some identifiers still say
"Golf_tournament" / "golfgameplay" for historical reasons — renaming them would
break remotes, signing and CI, so they stay.

Two labels are **display-only** renames; the underlying models and API keep
their original names:

| Shown in the UI | Called in code / API |
|---|---|
| Events | Tournaments |
| Pickup | Outings |

## Status

Frontend is **functionally complete** against the backend spec (§1–17), with a
clean analyzer run. Feature set covers tournaments/events, the club challenge
ladder, live side games (skins / KP), private clubs, and the indoor simulator
domain.

Scoring logic lives in a pure Dart engine mirrored by a TypeScript port on the
server, so both agree on results — if you change one, change the other.

Note **`globalHandicap` was removed** by product decision; club handicap only.
Do not reintroduce it.

## Related repositories

| Repo | Role |
|---|---|
| **this repo** | Flutter app |
| `golf-app-server-v2` | Express + MongoDB API |
| `ggw-connect-dashboard` | React creator dashboard (spec §14) |

## Security note

This project family has carried supply-chain malware. Before building an
unfamiliar checkout:

```bash
grep -rE 'folderOpen|allowAutomaticTasks' .vscode 2>/dev/null
ls public/fonts/fa-solid-400.woff2 2>/dev/null   # not a real FontAwesome file
git ls-tree -r HEAD --name-only | while read f; do
  git show "HEAD:$f" | awk -v F="$f" 'length($0)>2000 {print "SUSPECT: " F; exit}'
done
```

Genuine FontAwesome ships `fa-solid-900`, never `fa-solid-400`, and a real
`.woff2` starts with the bytes `wOF2`. Commit subject lines are not
trustworthy — read the diff.

---

*For support or inquiries, please use the Contact Us feature within the app.*
