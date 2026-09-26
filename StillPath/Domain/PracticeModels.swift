import Foundation
import SwiftData

enum PracticeKind: String, Codable, CaseIterable, Identifiable {
    case stillness, prayer, meditation, reading, gratitude, reflection, breathing, journaling, contemplation, custom
    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .stillness: "sparkles"; case .prayer: "hands.sparkles"; case .meditation: "figure.mind.and.body"
        case .reading: "text.book.closed"; case .gratitude: "heart"; case .reflection: "water.waves"
        case .breathing: "wind"; case .journaling: "square.and.pencil"; case .contemplation: "moon.stars"; case .custom: "plus"
        }
    }
}

enum FaithTradition: String, Codable, CaseIterable, Identifiable {
    case christianity, islam, judaism, hinduism, buddhism, sikhism, bahai, spiritual, contemplative, mindfulness, multiple, unspecified, custom
    var id: String { rawValue }
}

@Model final class PracticeRoutine {
    @Attribute(.unique) var id: UUID
    var name: String
    var isArchived: Bool
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \PracticeBlock.routine) var blocks: [PracticeBlock]

    init(name: String, blocks: [PracticeBlock] = []) {
        id = UUID(); self.name = name; isArchived = false; createdAt = .now; self.blocks = blocks
    }

    var totalSeconds: Int { blocks.compactMap(\.durationSeconds).reduce(0, +) }
}

@Model final class PracticeBlock {
    @Attribute(.unique) var id: UUID
    var kindRawValue: String
    var title: String
    var prompt: String?
    var durationSeconds: Int?
    var sortOrder: Int
    var isOptional: Bool
    var routine: PracticeRoutine?

    init(kind: PracticeKind, title: String, durationSeconds: Int? = nil, prompt: String? = nil, sortOrder: Int = 0, isOptional: Bool = false) {
        id = UUID(); kindRawValue = kind.rawValue; self.title = title; self.durationSeconds = durationSeconds; self.prompt = prompt; self.sortOrder = sortOrder; self.isOptional = isOptional
    }
    var kind: PracticeKind { PracticeKind(rawValue: kindRawValue) ?? .custom }
}

struct SessionPlan: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let stages: [SessionStage]
}

struct SessionStage: Identifiable, Hashable {
    let id = UUID()
    let kind: PracticeKind
    let title: String
    let prompt: String?
    let durationSeconds: Int?
}

@Model final class PracticeSession {
    @Attribute(.unique) var id: UUID
    var routineName: String
    var startedAt: Date
    var endedAt: Date
    var completedStageCount: Int
    var categoryRawValue: String
    init(routineName: String, startedAt: Date, endedAt: Date, completedStageCount: Int, category: PracticeKind) {
        id = UUID(); self.routineName = routineName; self.startedAt = startedAt; self.endedAt = endedAt; self.completedStageCount = completedStageCount; categoryRawValue = category.rawValue
    }
}

