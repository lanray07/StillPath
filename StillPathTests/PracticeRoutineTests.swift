import XCTest
@testable import StillPath

final class PracticeRoutineTests: XCTestCase {
    func testTotalDurationIgnoresUntimedReflection() {
        let routine = PracticeRoutine(name: "Morning", blocks: [PracticeBlock(kind: .stillness, title: "Stillness", durationSeconds: 60), PracticeBlock(kind: .reflection, title: "Reflect")])
        XCTAssertEqual(routine.totalSeconds, 60)
    }

    func testEveryPracticeKindHasStableSymbol() {
        XCTAssertTrue(PracticeKind.allCases.allSatisfy { !$0.symbol.isEmpty })
    }

    func testLocalCompanionDoesNotClaimToBeAI() async throws {
        let result = try await LocalReflectionCompanion().prompt(for: ReflectionRequest(userText: nil, practiceKinds: [.gratitude]))
        XCTAssertFalse(result.isAIGenerated)
        XCTAssertFalse(result.text.isEmpty)
    }

    func testTranslationMockNeverPretendsToTranslate() async {
        do { _ = try await LocalTranslationService().translate("Private text", to: "es"); XCTFail("Expected explicit unavailable error") }
        catch { XCTAssertTrue(error is TranslationUnavailableError) }
    }
}

