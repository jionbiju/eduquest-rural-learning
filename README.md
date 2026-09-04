

<h1 align="center">EduQuest 🎓🚀</h1>

<p align="center">
  <strong>A gamified, offline-first learning platform built for rural school students in India.</strong><br/>
  Bilingual • Gamified • Offline-Ready • Teacher-Powered
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-^3.5.0-0175C2?logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth%20%7C%20Storage-FFCA28?logo=firebase&logoColor=black" alt="Firebase"/>
  <img src="https://img.shields.io/badge/Riverpod-2.x-00B4D8?logo=flutter&logoColor=white" alt="Riverpod"/>
  <img src="https://img.shields.io/badge/Hive-Offline%20First-FF6B6B" alt="Hive"/>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-brightgreen" alt="Platform"/>
  <img src="https://img.shields.io/badge/License-MIT-blue" alt="License"/>
</p>

---

## 📖 Table of Contents

- [About the Project](#-about-the-project)
- [Key Features](#-key-features)
- [Tech Stack](#-tech-stack)
- [Architecture](#-architecture)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Firebase Setup](#-firebase-setup)
- [Firestore Schema](#-firestore-schema)
- [Roles & User Flows](#-roles--user-flows)
- [Offline-First Strategy](#-offline-first-strategy)
- [Gamification System](#-gamification-system)
- [Roadmap](#-roadmap)
- [Contributing](#-contributing)

---

## 🌟 About the Project

**EduQuest** bridges the educational gap for students in rural India by combining gamified learning mechanics with an offline-first architecture — designed to work reliably even in areas with limited internet connectivity.

The app supports a **dual-role system**:
- 🎒 **Students** explore bilingual lessons, earn XP, maintain streaks, and compete on leaderboards.
- 🧑‍🏫 **Teachers** author lessons in English & Hindi, publish them to their class/village group, and track student progress through an intelligent dashboard.

> _Built as a hackathon project to demonstrate how technology can empower grassroots education in India._

---

## ✨ Key Features

### 🎒 Student Experience

| Feature | Description |
|---|---|
| **Bilingual Lessons** | Toggle between Hindi 🇮🇳 and English 🇬🇧 on any lesson |
| **Voice Narration (TTS)** | Text-to-speech read-along with per-sentence highlighting, works on native & web |
| **Interactive Playground** | Subject-specific interactive mini-games per lesson topic |
| **Gamified Quizzes** | MCQ quizzes with XP rewards, streaks, and instant feedback |
| **XP & Level System** | Earn XP for completing lessons, answering correctly, and listening to narration |
| **Daily Streaks** | 🔥 Streak tracking to encourage daily engagement |
| **Badges** | Unlock achievement badges for milestones |
| **Leaderboard** | Class-wide leaderboard to spark healthy competition |
| **Offline Mode** | All content cached locally via Hive — works without internet |
| **Sync on Reconnect** | Progress syncs to Firebase when connectivity returns |

### 🧑‍🏫 Teacher Experience

| Feature | Description |
|---|---|
| **Role-Based Auth** | Separate signup flow for teachers and students |
| **Teacher Dashboard** | Real-time class analytics with data-driven insights |
| **Class Pulse** | Auto-generated daily summary: "18 of 22 students studied today (82%)" |
| **Struggling Topic Alert** | Flags topics where >40% of students scored <50% |
| **Student Progress Cards** | XP, streak, level, and weakest-topic chip per student |
| **Lesson Authoring** | Create lessons with text, audio, images, and quiz questions |
| **Draft & Publish** | Save lessons as drafts, preview them, then publish to students |
| **Group Scoping** | Lessons are scoped to a teacher's class/village group (`groupId`) |
| **Real-Time Updates** | Dashboard updates live via Firestore streams |

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (Dart ^3.5.0) |
| **State Management** | Riverpod 2.x + `riverpod_annotation` |
| **Local Storage** | Hive 2.x (offline-first cache) |
| **Backend** | Firebase (Auth, Cloud Firestore, Storage) |
| **Routing** | go_router 14.x |
| **Text-to-Speech** | flutter_tts 4.x (native + Web SpeechSynthesis API) |
| **UI / Animations** | Lottie, shimmer, Google Fonts, flutter_svg |
| **Networking** | connectivity_plus (online/offline detection) |
| **Utilities** | freezed, json_annotation, equatable, uuid, intl |
| **Platforms** | Android · iOS · Web · (Linux · macOS · Windows) |

---

## 🏗 Architecture

EduQuest follows a **clean, feature-first architecture** with clear separation of concerns:

```
Presentation Layer  →  Riverpod Providers  →  Repository Layer  →  Data Sources
(Screens/Widgets)       (State / Logic)        (Data Access)        (Hive / Firebase)
```

### Design Principles

- **Offline-First**: Hive acts as the source of truth. Firebase syncs in the background via a queue.
- **Feature Isolation**: Each feature (`auth`, `lessons`, `quiz`, `leaderboard`, `teacher_content`, etc.) is fully self-contained.
- **Reactive UI**: Riverpod providers expose streams so the UI reactively rebuilds when data changes — locally or from Firestore.
- **Bilingual by Design**: All content models carry `{ en: string, hi: string }` fields. The UI language can be toggled at any time.

### Sync Architecture

```
Student App                    Firestore
┌─────────────┐               ┌─────────────┐
│  Hive Cache │ ◄── sync ──── │   lessons   │
│  (offline)  │               │  collection │
└─────────────┘               └─────────────┘
      ▲                              ▲
      │ write                        │ publish
      │                              │
  Student XP              Teacher Dashboard
  Quiz Progress           (Lesson Authoring)
      │                              │
      └──── student_progress ────────┘
              collection
```

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── constants/          # App-wide constants (XP values, box names)
│   ├── router/             # go_router config with role-based redirects
│   ├── services/           # Firebase & Firestore service wrappers
│   ├── theme/              # Colors, text styles, app theme
│   ├── utils/              # Helpers & utilities
│   └── widgets/            # Shared reusable widgets
│
└── features/
    ├── auth/               # Login, signup, role selection
    ├── home/               # Student home screen, subject grid
    ├── lessons/            # Lesson screen, TTS, illustrations, playground
    ├── quiz/               # MCQ quiz engine, answer feedback, XP award
    ├── leaderboard/        # Class-wide leaderboard
    ├── profile/            # Student profile, badges, level card
    ├── settings/           # Language preference, settings
    ├── teacher_content/    # Teacher dashboard, lesson authoring, analytics
    ├── sms/                # SMS-based notifications (rural-friendly)
    └── sync/               # Offline sync queue & connectivity handling

assets/
├── audio/                  # Bundled audio clips
├── bundles/                # sample_bundle.json (offline lesson content)
├── images/                 # Illustrations, stitch animations
└── lottie/                 # Lottie animation files
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.5.0` — [Install Flutter](https://flutter.dev/docs/get-started/install)
- Dart SDK `^3.5.0`
- A Firebase project (see [Firebase Setup](#-firebase-setup))

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/jionbiju/eduquest.git
cd eduquest

# 2. Install dependencies
flutter pub get

# 3. Run on your device/emulator
flutter run
```

### Platform-specific builds

```bash
# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios

# Web
flutter run -d chrome
```

---

## 🔥 Firebase Setup

1. **Create a Firebase project** at [console.firebase.google.com](https://console.firebase.google.com)

2. **Enable Authentication**
   - Go to Authentication → Sign-in method → Enable **Email/Password**

3. **Enable Cloud Firestore**
   - Firestore Database → Create database
   - Apply security rules from [`FIRESTORE_SCHEMA.md`](FIRESTORE_SCHEMA.md)

4. **Enable Firebase Storage** (for teacher audio/image uploads)

5. **Add your app**
   - Android: download `google-services.json` → place in `android/app/`
   - iOS: download `GoogleService-Info.plist` → place in `ios/Runner/`
   - Web: add Firebase config to `web/index.html`

6. **Create Firestore Composite Indexes**

   | Collection | Fields |
   |---|---|
   | `users` | `groupId` (ASC) + `role` (ASC) |
   | `lessons` | `groupId` (ASC) + `status` (ASC) + `createdAt` (DESC) |
   | `lessons` | `authorUid` (ASC) + `createdAt` (DESC) |
   | `student_progress` | `groupId` (ASC) + `lastActive` (DESC) |

---

## 🗄 Firestore Schema

Three primary collections power the app:

### `users`
Stores profiles for both students and teachers. Role-based fields allow the app to route users correctly.

```json
{
  "uid": "abc123",
  "email": "student@example.com",
  "displayName": "Ravi Kumar",
  "role": "student",
  "groupId": "village_01",
  "xp": 1450,
  "streak": 7,
  "level": 5,
  "badges": ["first_lesson", "week_streak"],
  "language": "hi"
}
```

### `lessons`
Teacher-authored lessons, scoped to a `groupId`. Supports bilingual content, quizzes, and media.

```json
{
  "topicId": "math_addition_123",
  "topicName": { "en": "Addition Basics", "hi": "जोड़ की मूल बातें" },
  "subjectId": "math",
  "difficulty": 1,
  "lessonText": { "en": "...", "hi": "..." },
  "questions": ["..."],
  "groupId": "village_01",
  "status": "published",
  "completionCount": 15,
  "averageScore": 78.5
}
```

### `student_progress`
Per-student progress tracking including completed lessons, topic accuracy, and weakest topic detection.

```json
{
  "studentUid": "xyz789",
  "completedLessons": ["math_addition", "science_plants"],
  "topicAccuracy": { "math_addition": 95.0, "science_plants": 80.0 },
  "weakestTopic": { "topicId": "math_subtraction", "accuracy": 45.0 },
  "lastActive": "2026-09-04T09:15:00Z"
}
```

> 📄 Full schema with security rules: [`FIRESTORE_SCHEMA.md`](FIRESTORE_SCHEMA.md)

---

## 👥 Roles & User Flows

### Student Flow
```
Sign Up (Student role) → Enter GroupId
        ↓
  Home Screen → Subject Grid → Lesson Screen
                                    ↓
                       TTS Read-Along + Interactive Playground
                                    ↓
                              Start Quiz → Earn XP → Level Up
                                    ↓
                           Progress syncs to Firestore
```

### Teacher Flow
```
Sign Up (Teacher role) → Enter GroupId
        ↓
  Teacher Dashboard → Class Pulse Summary
        ↓              Struggling Topic Alerts
  Create Lesson →     Student Progress Cards
        ↓
  Draft → Edit → Preview → Publish
        ↓
  Students see new lesson on next sync
        ↓
  Dashboard analytics update in real-time
```

---

## 📶 Offline-First Strategy

EduQuest is built to work reliably in low-connectivity environments:

| Scenario | Behavior |
|---|---|
| **No internet** | Students access all cached lessons and continue earning XP locally |
| **Quiz completion** | Progress stored in Hive sync queue |
| **Back online** | Sync queue flushes to Firestore automatically |
| **New lessons** | Student app checks for new published lessons on startup / reconnect |
| **Teacher authoring** | Drafts saved locally, published when online |

The sync engine uses a `SyncQueueRepository` backed by a Hive box. All write operations are enqueued and replayed in order when connectivity is restored.

---

## 🎮 Gamification System

| Action | XP Reward |
|---|---|
| Correct quiz answer | +10 XP |
| Complete a lesson | +20 XP |
| Listen to full voice narration | +15 XP |
| Daily streak maintained | Bonus multiplier |

**Level Progression**: XP thresholds increase each level, encouraging continued engagement.

**Badges**: Unlockable achievements including first lesson, weekly streak, subject mastery, and more.

**Leaderboard**: Class-scoped rankings — students compete with their village group peers, fostering community learning.

---

## 🗺 Roadmap

- [x] Offline-first Hive storage
- [x] Firebase Auth (Email/Password)
- [x] Bilingual lessons (English + Hindi)
- [x] Voice narration with per-sentence highlighting (TTS)
- [x] Interactive lesson playground
- [x] MCQ quiz engine with XP rewards
- [x] Daily streak system
- [x] Leaderboard
- [x] Role-based authentication (Student / Teacher)
- [x] Teacher dashboard with Class Pulse & Struggling Topic alerts
- [x] Firestore backend with group-scoped lessons
- [x] Real-time state management via Riverpod streams
- [ ] Lesson authoring form (multi-step wizard)
- [ ] Firebase Storage audio/image upload
- [ ] Dynamic student-side Firestore lesson sync
- [ ] Student detail view for teachers
- [ ] Content Reach analytics (completionCount, averageScore)
- [ ] SMS-based lesson delivery for feature phones
- [ ] Push notifications for new lessons

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

Please ensure your code follows the existing architecture patterns and passes `flutter analyze`.

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ❤️ for rural India 🇮🇳 &nbsp;|&nbsp; Built with Flutter 💙
</p>
