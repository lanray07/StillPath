import Foundation

struct ReflectionRequest: Sendable {
    let userText: String?
    let practiceKinds: [PracticeKind]
}

struct GeneratedReflection: Sendable {
    let text: String
    let isAIGenerated: Bool
}

protocol ReflectionCompanion: Sendable {
    func prompt(for request: ReflectionRequest) async throws -> GeneratedReflection
}

struct LocalReflectionCompanion: ReflectionCompanion {
    func prompt(for request: ReflectionRequest) async throws -> GeneratedReflection {
        let prompt: String
        if request.practiceKinds.contains(.gratitude) { prompt = String(localized: "reflection.prompt.gratitude") }
        else if request.practiceKinds.contains(.reading) { prompt = String(localized: "reflection.prompt.stayed") }
        else { prompt = String(localized: "reflection.prompt.attention") }
        return GeneratedReflection(text: prompt, isAIGenerated: false)
    }
}

protocol TranslationService: Sendable {
    func translate(_ source: String, to languageCode: String) async throws -> TranslationResult
}

struct TranslationResult: Sendable {
    let original: String
    let translated: String
    let targetLanguageCode: String
    let isAutomatic: Bool
}

struct LocalTranslationService: TranslationService {
    func translate(_ source: String, to languageCode: String) async throws -> TranslationResult {
        throw TranslationUnavailableError()
    }
}

struct TranslationUnavailableError: LocalizedError {
    var errorDescription: String? { String(localized: "translation.unavailable") }
}

protocol AnalyticsClient: Sendable { func record(_ event: AnalyticsEvent) }
enum AnalyticsEvent: Sendable { case onboardingCompleted, practiceStarted(kind: PracticeKind), practiceCompleted, journalCreated, paywallViewed, purchaseCompleted(productID: String) }
struct PrivacyPreservingAnalytics: AnalyticsClient { func record(_ event: AnalyticsEvent) { /* Opt-in production sink. Never attach private content. */ } }

