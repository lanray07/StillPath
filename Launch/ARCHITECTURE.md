# StillPath architecture

## Product boundary

StillPath is local-first. The app shell owns navigation and session presentation; SwiftData owns routines, blocks, journal entries, and completed sessions. No account or network connection is required for the core loop.

## Modules

- **App**: root dependency graph, tabs, deep links, App Intents.
- **Domain**: persisted models plus small value types for in-progress sessions.
- **Features**: composed SwiftUI screens with local state and explicit environment dependencies.
- **Services**: StoreKit, reminders, biometrics, AI, translation, and analytics interfaces.
- **Widgets**: intentionally displays no private journal content.

## Sensitive-data flow

```text
typed/dictated reflection → JournalEntry → local SwiftData store
                              ├─ export (explicit user action)
                              ├─ AI provider (off by default; explicit consent)
                              ├─ translation (off by default; original retained)
                              └─ sync (off by default; not configured)
```

Production AI and translation adapters must never receive journal content unless the matching control is enabled. Payloads should be minimized, transmitted with TLS, excluded from provider training and logs by contract, and deleted according to a documented retention schedule. AI output must be labeled and must never be represented as scripture or spiritual authority.

## Content integrity

The repository intentionally ships no sourced sacred-text library. Before adding one, every item needs title, tradition, source, author where applicable, translation/version, attribution, and license metadata. User-authored and machine-generated content must remain visually and structurally distinct.

## Remaining production integrations

- Add an encrypted-at-rest storage policy appropriate to the final threat model and verify iOS Data Protection classes.
- Add audio capture/transcription after finalizing recording retention and deletion UX.
- Implement a vetted translation adapter and optional AI adapter.
- Add iCloud/CloudKit only after sync conflict and deletion semantics are approved.
- Connect an opt-in analytics backend that accepts event names only.
- Add final licensed content after editorial and legal review.

