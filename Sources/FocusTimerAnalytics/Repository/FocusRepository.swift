import Foundation

/// In-memory repository for focus sessions.
/// In production this would be backed by a database (Core Data, SwiftData, etc.).
///
/// This is the data source for your analytics module.
/// Use getAllSessions() to access the session history,
/// then build your analytics logic on top of this data.
///
/// Feel free to review this code — you may want to consider
/// how it affects the testability of your analytics module.
public class FocusRepository {

    private var sessions: [FocusSession] = []

    public init() {
        let now = Date()
        let calendar = Calendar.current

        func dateAt(daysAgo: Int, hour: Int, minute: Int) -> Date {
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.hour = hour
            components.minute = minute
            components.second = 0
            let today = calendar.date(from: components)!
            return calendar.date(byAdding: .day, value: -daysAgo, to: today)!
        }

        sessions = [
            // Today — two sessions at different times
            FocusSession(durationMinutes: 25, completedAt: dateAt(daysAgo: 0, hour: 9, minute: 0), label: "Morning Reading"),
            FocusSession(durationMinutes: 50, completedAt: dateAt(daysAgo: 0, hour: 20, minute: 0), label: "Evening Deep Work"),

            // Yesterday
            FocusSession(durationMinutes: 25, completedAt: dateAt(daysAgo: 1, hour: 14, minute: 30), label: "Afternoon Study"),

            // 2 days ago
            FocusSession(durationMinutes: 45, completedAt: dateAt(daysAgo: 2, hour: 10, minute: 0), label: "Writing"),

            // 3 days ago — no session (gap)

            // 4 days ago
            FocusSession(durationMinutes: 25, completedAt: dateAt(daysAgo: 4, hour: 15, minute: 0), label: "Coding"),

            // 5 days ago
            FocusSession(durationMinutes: 30, completedAt: dateAt(daysAgo: 5, hour: 8, minute: 0), label: "Design"),

            // 6 days ago
            FocusSession(durationMinutes: 50, completedAt: dateAt(daysAgo: 6, hour: 19, minute: 0), label: "Planning"),

            // 7 days ago
            FocusSession(durationMinutes: 25, completedAt: dateAt(daysAgo: 7, hour: 13, minute: 0), label: "Review"),

            // 8 days ago
            FocusSession(durationMinutes: 40, completedAt: dateAt(daysAgo: 8, hour: 11, minute: 0), label: "Research"),

            // 9 days ago
            FocusSession(durationMinutes: 25, completedAt: dateAt(daysAgo: 9, hour: 16, minute: 0), label: "Documentation"),

            // 10 days ago
            FocusSession(durationMinutes: 35, completedAt: dateAt(daysAgo: 10, hour: 9, minute: 30), label: "Analysis"),

            // 11 days ago — no session (gap)

            // 14 days ago — isolated session
            FocusSession(durationMinutes: 25, completedAt: dateAt(daysAgo: 14, hour: 10, minute: 0), label: "Old Task"),
        ]
    }

    public func getAllSessions() -> [FocusSession] {
        return sessions
    }

    public func saveSession(_ session: FocusSession) {
        DispatchQueue.global().async {
            self.sessions.insert(session, at: 0)
        }
    }

    public func deleteSession(id: UUID) {
        DispatchQueue.global().async {
            self.sessions.removeAll { $0.id == id }
        }
    }
}
