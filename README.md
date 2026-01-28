# MindLink AI - Malayalam Voice Typing

Native Flutter app for Malayalam voice-to-text transcription.

## Features

- 🎙️ Real-time Malayalam voice typing
- 🎯 99% accuracy with Kerala dialect support
- 📋 Copy, share, and export transcriptions
- 📜 Transcription history
- 🌙 Dark theme matching web app
- 🔒 Privacy-first (no data stored on servers)

## Requirements

- Flutter 3.10+
- Android Studio (for Android builds)
- Xcode (for iOS builds)

## Setup

```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Build release APK
flutter build apk --release

# Build for Play Store (AAB)
flutter build appbundle --release
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── providers/
│   └── transcription_provider.dart  # State management
├── screens/
│   ├── home_screen.dart      # Main voice typing screen
│   └── history_screen.dart   # Transcription history
├── services/
│   └── transcription_service.dart   # API & recording
└── widgets/                  # Reusable widgets
```

## API

The app connects to `https://mindlink-ai.com/api/transcribe` for speech-to-text processing.

## Play Store Listing

**App Name:** MindLink AI - Malayalam Voice Typing

**Short Description:**
Free Malayalam voice typing. Speak and convert to text instantly with 99% accuracy.

**Full Description:**
MindLink AI is the best Malayalam voice typing app for Android. Simply speak in Malayalam and watch your words appear as text instantly.

✅ 99% accuracy for Malayalam speech
✅ Supports all Kerala dialects (Thrissur, Malabar, Kochi, Trivandrum)
✅ Real-time transcription
✅ Copy to clipboard or share anywhere
✅ Transcription history
✅ Dark theme for comfortable use
✅ Privacy-first - your voice is not stored

Perfect for:
- WhatsApp messages in Malayalam
- YouTube script writing
- Students taking notes
- Lawyers drafting documents
- Content creators
- Anyone who finds Malayalam typing difficult

Download now and type Malayalam 5x faster by speaking!

**Keywords:** Malayalam voice typing, Malayalam speech to text, voice to text Malayalam, Malayalam keyboard, Malayalam dictation
```

## License

Proprietary - MindLink AI
