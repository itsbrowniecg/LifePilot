# LifePilot

**An AI-powered personal utility app that turns everyday chaos into clear next actions.**

Bills, tasks, groceries, and appointments pile up in different places. LifePilot pulls them into one inbox, figures out what actually matters *right now*, and hands you a short, prioritized action list — so your day starts with a plan instead of a scroll through five different apps.

---

## ✨ Features

- **Home dashboard — "What should I do now?"**
  A time-of-day-aware view that surfaces your top 3 most urgent items (overdue tasks, bills due soon, expiring groceries, upcoming appointments), ranked automatically.

- **Life Inbox**
  Drop anything in — type it, snap a photo, or scan a receipt — and LifePilot sorts it into the right category (task, bill, grocery, or appointment).

- **Receipt & text scanning**
  On-device OCR (via Apple Vision) reads photos and receipts, no upload required.

- **Pantry & Bills tracking**
  See what's expiring soon and what's due, at a glance.

- **Calendar & Reminders integration**
  One tap to send an appointment to Calendar or a task to Reminders.

- **Demo Mode**
  The app seeds itself with realistic sample data on first launch, so it's fully explorable with zero setup.

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI |
| Persistence | SwiftData |
| Text recognition | Vision (on-device OCR) |
| System integration | EventKit (Calendar & Reminders) |
| Analysis | Local rules-based service behind an `AIServiceProtocol` boundary |

**Why a local AI service?** LifePilot's analysis engine is built behind a protocol interface (`AIServiceProtocol`) rather than hardcoded. Right now it runs as an on-device mock — this keeps captured text private (nothing leaves the device) and keeps demos reliable with no network dependency. Because it's protocol-based, swapping in a real hosted LLM later is a drop-in change, not a rewrite.

---

## 🚀 Getting Started

1. Clone the repo:
   ```bash
   git clone https://github.com/itsbrowniecg/LifePilot.git
   ```
2. Open `LifePilot.xcodeproj` in **Xcode 16+**.
3. Select an iOS 17+ simulator (or a physical device).
4. Build and run — **no API keys or `.env` file needed.** LifePilot seeds itself with demo data on first launch.

---

## 📂 Project Structure

LifePilot/
├── App/                 # App entry point, SwiftData container setup
├── Models/              # SwiftData models: Task, Bill, Grocery, Appointment, InboxItem
├── Services/            # AIService, OCRService, EventKitService, PrioritizationService
├── Views/
│   ├── Home/            # "What should I do now?" dashboard
│   ├── Inbox/           # Capture flow: text, photo, camera
│   ├── Tasks/
│   ├── Pantry/
│   └── Profile/
└── Components/          # Reusable UI pieces

---

## 🗺 Roadmap

- [ ] Real hosted AI backend (swap behind the existing `AIServiceProtocol`)
- [ ] Budget tracking tied to bills and groceries
- [ ] Smart notifications for upcoming deadlines
- [ ] Two-way calendar sync (not just one-way add)
