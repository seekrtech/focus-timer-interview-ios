import Foundation

public struct FocusSession: Identifiable, Equatable {
    public let id: UUID
    public let durationMinutes: Int
    public let completedAt: Date
    public let label: String

    public init(
        id: UUID = UUID(),
        durationMinutes: Int,
        completedAt: Date,
        label: String = ""
    ) {
        self.id = id
        self.durationMinutes = durationMinutes
        self.completedAt = completedAt
        self.label = label
    }
}
