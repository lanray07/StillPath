# StillPath

StillPath is a privacy-first, inclusive prayer, meditation, and reflection app for iPhone and iPad.

## Generate and run

Requirements: macOS, Xcode 16 or newer, and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```sh
brew install xcodegen
xcodegen generate
open StillPath.xcodeproj
```

Select the `StillPath` scheme and an iOS 17+ simulator. No credentials are required for the local experience.

## GitHub Xcode builds

`.github/workflows/ios.yml` generates the project on a GitHub-hosted Mac and compiles the app, widget, and unit-test bundle on every push and pull request. From the Actions tab, enable **run_simulator_tests** to boot an iPhone simulator and execute tests. Enable **signed_archive** to use the configured App Store Connect secrets, create a signed archive, export an IPA, and retain it as a private workflow artifact. The workflow does not upload a build to TestFlight or submit it for review.

## Production setup

- Replace the placeholder App Store identifiers in `project.yml` if the final bundle ID changes.
- Create monthly and annual auto-renewable subscriptions matching `StillPath/Configuration/StillPath.storekit` in App Store Connect.
- Keep `LocalReflectionCompanion` as the default. A production AI provider must conform to `ReflectionCompanion`, obtain explicit opt-in, minimize journal payloads, and explain off-device processing.
- `LocalTranslationService` preserves source text and marks its sample output as automatic. Connect Apple Translation or a vetted provider behind `TranslationService` before shipping translation.
- Notifications, speech recognition, microphone access, and biometrics are requested only at the point of use.
- Add an App Group and iCloud container only after the corresponding privacy controls and account UX are finalized.

## Privacy boundaries

Journal content is stored locally with SwiftData. Analytics records event names and coarse UI context only—never journal text, prompts, recordings, religion, or search queries. AI, translation, cloud sync, and widget privacy are off by default.

## Project map

- `StillPath/App`: app shell, navigation, dependency graph, and intents
- `StillPath/DesignSystem`: design tokens and reusable components
- `StillPath/Domain`: SwiftData models and product vocabulary
- `StillPath/Features`: onboarding, home, practices, journal, history, premium, and settings
- `StillPath/Services`: privacy-sensitive protocol boundaries and local implementations
- `StillPathWidgets`: privacy-safe widgets
- `StillPathTests`: domain and service tests
- `Launch`: App Store metadata, privacy notes, QA, screenshot plan, and localization guidance

