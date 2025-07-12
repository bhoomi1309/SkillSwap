# 🚀 Skill Swap Platform

A comprehensive **Flutter application** that empowers users to exchange their skills with others. Whether you're a designer who wants to learn coding or a chef looking to teach in return for photography lessons — **Skill Swap** makes it happen!

---

## 👥 Team Members

| Name              | Email Address                                                |
|-------------------|--------------------------------------------------------------|
| Shreya Keraliya   | [shreyakeraliya0@gmail.com](mailto:shreyakeraliya0@gmail.com) |
| Bhoomi Tulsiyani  | [tulsiyanibhoomi@gmail.com](mailto:tulsiyanibhoomi@gmail.com) |
| Birva Vaghasiya   | [birvaa1409@gmail.com](mailto:birvaa1409@gmail.com)           |
| Komal Gangani     | [23010101084@darshan.ac.in](mailto:23010101084@darshan.ac.in) |

---

## 📌 Problem Statement – Chosen: **Problem Statement 1**

### 🔄 Skill Swap Platform

> Develop a mini-application that enables users to list their skills and request others in return.

### ✅ Features Covered:
- Basic info: Name, location (optional), profile photo (optional)
- List of skills offered and wanted
- Availability (e.g., weekends, evenings)
- Profile visibility: Public/Private
- Browse/Search users by skill (e.g., Photoshop)
- Swap Request system:
  - Accept or reject swap offers
  - View current/pending/completed requests
  - Delete unaccepted outgoing requests
- ⭐ Ratings and feedback after a swap
- 🛡️ Admin Panel:
  - Approve/Reject skill listings
  - Ban users
  - Monitor swap activity
  - Send platform-wide messages
  - Export data reports

---

## ✨ Features

### 🔐 Authentication
- Login/Register with toggle
- Form validation
- Error handling and feedback

### 👤 User Dashboard
- Display user info, photo, availability
- Skills Offered & Wanted
- Profile Privacy toggle
- Edit info easily

### 🔍 Browse Users
- Search users by skill
- View user cards with skill info
- Send swap requests

### 📋 Swap Requests
- Incoming and Outgoing tabs
- Accept/Reject buttons
- Status indicators (Pending, Completed)
- Delete option for unaccepted requests

### ⭐ Feedback System
- Star rating UI (1-5)
- Optional comment box
- Feedback modal
- History of feedback

### 🛠️ Admin Panel
- Approve/Reject skills
- Ban users violating policy
- Monitor swap status
- Announce updates
- Download logs and reports

---

## 🎨 UI/UX Highlights

- ✅ **Material Design**: Modern and familiar
- 🌗 **Light/Dark Theme Toggle**
- 🎯 **Responsive Layout**: Mobile-first experience
- 🟦 **Color Palette**: Calm blue/green tones
- 🧱 **Flutter Widgets Used**:
  - `ListView`, `Card`, `TextFormField`, `Switch`, `DropdownButton`, `BottomNavigationBar`, `CircleAvatar`, `Chip`, etc.

---

## 📁 Project Structure

lib/
├── main.dart
├── providers/
│ ├── auth_provider.dart
│ ├── user_provider.dart
│ └── swap_provider.dart
└── screens/
├── login_screen.dart
├── dashboard_screen.dart
├── browse_users_screen.dart
├── swap_requests_screen.dart
├── feedback_screen.dart
└── admin_panel_screen.dart



---

## 🛠️ Tech Stack

- **Flutter 3.0+**
- **Dart**
- **Provider** (state management)
- **Shared Preferences**
- **Image Picker**
- **Cached Network Image**

---

## 📦 Dependencies

| Package                | Purpose                        |
|------------------------|--------------------------------|
| `provider`             | State management               |
| `http`                 | Networking/API (future use)    |
| `shared_preferences`   | Local storage (user settings)  |
| `image_picker`         | Upload profile images          |
| `cached_network_image` | Optimized image loading        |

---

## 🧪 Mock Data & Scenarios

### 👤 Users
- John Doe – Web Dev, Design
- Sarah Johnson – Cooking, Yoga
- Emily Davis – Photography, French
- Mike Chen – Guitar, Spanish
- Alex Rodriguez – Soccer, Portuguese

### 🔄 Swap Requests
- Pending, completed, and rejected samples

### ⭐ Feedback
- Mock ratings and comments

---

## 🧭 Getting Started

### 🧰 Prerequisites
- Flutter SDK (3.0+)
- Dart SDK
- Android Studio / VS Code
- Emulator or physical device

### 🚀 Installation

```bash
git clone https://github.com/ShreyaKeraliya/SkillSwap.git
cd SkillSwap
flutter pub get
flutter run
