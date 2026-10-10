<h1 align="center">📝 NoteX</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/GetX-8A2BE2?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Clean%20Architecture-2E7D32?style=for-the-badge" />
</p>

<p align="center">
A modern notes app in Flutter built on Clean Architecture, with Firebase sync, colour labels and smooth animations.
</p>

## ✨ Features

- ✍️ **Create, edit and delete notes** with a dedicated editor and a details page.
- 🎨 **Colour labels** with a colour picker and a filter bar to show notes by colour.
- ☁️ **Cloud sync** with Cloud Firestore and Firebase Authentication.
- 💾 **Local data source** with shared_preferences.
- 📊 **Text stats** (word and character counts) and friendly date formatting.
- ✨ **Smooth UI**: fade and slide animations, hero transitions, loading skeletons and confirm sheets.
- 🌍 **Localization** support and Google Fonts.

## 🧱 Architecture

The app follows **Clean Architecture** with a feature-first layout:

```
lib/
├── core/                bindings, constants, theme, utils, shared widgets
└── features/
    ├── splash/
    └── notes/
        ├── data/            local & remote data sources, models, repository impl
        ├── domain/          entities, repository contract, use cases
        └── presentation/    GetX controllers, pages, widgets
```

Use cases: `AddNote`, `GetNotes`, `UpdateNote`, `DeleteNote`.

## 🛠️ Tech Stack

- **Flutter & Dart**
- **GetX** for state management and dependency injection
- **Firebase**: Core, Auth, Cloud Firestore
- **equatable**, **shared_preferences**, **google_fonts**

## 🚀 Getting Started

```bash
git clone https://github.com/Mohammed1Karam/NoteX.git
cd NoteX
flutter pub get
flutter run
```

> Connect your own Firebase project (`flutterfire configure`) before running.

## 👨‍💻 Author

**Mohammed Karam**, Flutter Developer · [GitHub](https://github.com/Mohammed1Karam)
