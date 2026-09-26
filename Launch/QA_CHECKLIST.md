# Release QA checklist

## Functional

- Complete and restart onboarding; change personalization later.
- Create, reorder, start, pause, advance, finish early, duplicate, archive, and delete a routine.
- Run a session with and without timers; background and foreground during a timer.
- Create, edit, favorite, tag, search, export, and delete journal entries.
- Verify subscription purchase, cancellation, grace period, expiration, family sharing, offline launch, and restore using StoreKit testing and Sandbox.
- Confirm subscription expiry never hides or deletes user-created content.
- Schedule reminders across DST and timezone changes; test all pause options.
- Run every deep link, Shortcut, Siri phrase, widget family, and accessibility action.

## Privacy and safety

- Confirm no permissions appear on first launch.
- Inspect network traffic with every privacy toggle off; no journal content may leave the device.
- Verify biometric lock after backgrounding, failure, cancellation, and biometrics changes.
- Verify delete-all removes journal entries, recordings, search indexes, cached translations, AI payloads, and synced copies where configured.
- Verify exports exclude items the user did not select and are cleaned from temporary storage.
- Confirm logs, crash reports, analytics, and notification payloads contain no reflection text, search terms, religion, or recordings.
- Red-team AI output for spiritual authority, fabricated scripture, crisis content, and unsafe medical/legal claims.

## Accessibility and localization

- VoiceOver: logical order, meaningful button labels, no image-only information.
- Dynamic Type from XS through AX5 without clipping; landscape and iPad split view.
- Reduce Motion, Differentiate Without Color, Bold Text, Increase Contrast, and Reduce Transparency.
- Full RTL review in Arabic and Urdu, including navigation direction, symbols, forms, calendars, and number/date formatting.
- Pseudolocalize at 40% expansion; verify German, Arabic, Urdu, Hindi, Japanese, Korean, and Simplified Chinese.
- Test hardware keyboard, Switch Control, Voice Control, and touch targets.

## Performance and resilience

- Cold launch, memory, hangs, and energy profiling on oldest supported hardware.
- Search with 10,000 entries; history with five years of data; long entries and large tag sets.
- Storage migration and corrupted-store recovery; low disk space; no network; interrupted purchases.

## Release gate

- Zero crashers and data-loss bugs.
- Privacy manifest, nutrition label, policy URLs, support URL, age rating, export compliance, and review notes match the shipped build.
- All screenshots show genuine current UI and omit private/user-identifying data.

