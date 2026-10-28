# DreamScape

DreamScape is a SwiftUI sleep and mindfulness companion for iOS 17+. It combines guided meditation, ambient sound mixing, breathing exercises, sleep-mode routines, morning check-ins, and lightweight sleep insights in a calm, glass-inspired interface.

> DreamScape is a wellness app, not a medical device. Its scores and insights are for reflection only and are not medical advice or a diagnosis.

## Highlights

- Personalized onboarding and a simple home dashboard
- Guided meditation library and meditation player
- Breathing circle for paced relaxation
- Ambient sound mixer for sleep sessions
- Sleep mode with bedtime routines and sleep logging
- Morning check-in and sleep score visualization
- Local app state with optional Firebase and StoreKit service integration points
- Liquid-glass design system, haptics, typography, and starfield backgrounds

## Tech stack

- Swift 6 and SwiftUI
- iOS 17+
- Xcode 26 project generation via [XcodeGen](https://github.com/yonaskolb/XcodeGen)
- Optional Firebase integration for backend services
- StoreKit service layer for future subscriptions

## Project structure

```text
DreamScape/
├── DreamScape.xcodeproj/       # Generated Xcode project
├── project.yml                 # XcodeGen project definition
└── DreamScape/
    ├── App/                    # App entry point and shared state
    ├── Components/             # Reusable visual and interaction components
    ├── DesignSystem/           # Theme, typography, glass effects, haptics
    ├── Models/                 # User, meditation, and sleep models
    ├── Services/               # Audio, insights, Firebase, and StoreKit layers
    ├── Views/                  # Onboarding, home, meditation, sleep, and settings
    └── Resources/              # Asset catalogs
```

## Requirements

- macOS with Xcode 26 or newer
- iOS 17.0 or newer (device or Simulator)
- Optional: XcodeGen if regenerating the project from `project.yml`
- Optional: Firebase configuration if enabling cloud-backed features

## Run in the iOS Simulator

1. Open `DreamScape.xcodeproj` in Xcode.
2. Select the **DreamScape** scheme.
3. Select an iPhone simulator running iOS 17 or newer, such as an iPhone 16 Pro.
4. Press **Run** (`⌘R`).
5. Walk through onboarding, then try Home, Meditation, Sleep Mode, Morning, and Settings.

Command-line preparation:

```bash
# Optional: regenerate after changing project.yml
xcodegen generate

# List available simulator destinations
xcrun simctl list devices available

# Build for a selected simulator
xcodebuild -project DreamScape.xcodeproj -scheme DreamScape -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -configuration Debug build
```

If CoreSimulator is unavailable, open the **Simulator** app and restart Xcode before retrying. A physical device requires a configured Apple Developer team and signing profile.

## Screenshot

Capture a real Home dashboard image from the running app:

```bash
mkdir -p docs
xcrun simctl io booted screenshot docs/dreamscape-home.png
```

Then embed it with `![DreamScape Home dashboard](docs/dreamscape-home.png)`. The repository does not include a fabricated screenshot; capture one from the current build so it stays accurate.

## Configuration and privacy

Keep Firebase files, signing assets, API keys, and local environment files out of Git. The included `.gitignore` excludes common credentials and Xcode-generated files. Before enabling a production backend, review data retention, consent, authentication, and analytics settings.

## Roadmap

- [ ] Add an onboarding screenshot tour and accessibility audit
- [ ] Persist sleep logs with SwiftData and add export/delete controls
- [ ] Connect Firebase authentication and secure per-user sync
- [ ] Finish StoreKit subscriptions and restore-purchases flow
- [ ] Add downloadable meditation and sound packs
- [ ] Add widgets, Live Activities, and Focus-mode shortcuts
- [ ] Add localization and VoiceOver-specific interaction polish
- [ ] Add unit/UI tests and CI builds for pull requests
- [ ] Publish TestFlight builds and collect structured beta feedback

## Contributing

Create a feature branch, keep changes focused, run the app on an iOS 17+ simulator, and include screenshots for meaningful UI changes. Do not commit secrets or generated build products.

## Support the project

If DreamScape helps you unwind, you can support continued development with a coffee:

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-support-FFDD00?logo=buy-me-a-coffee&logoColor=000000)](https://buymeacoffee.com/awaisdev572)

Every contribution helps fund new meditations, accessibility improvements, testing, and future releases.

## License

No license has been selected yet. Until one is added, all rights are reserved by the project owner.
