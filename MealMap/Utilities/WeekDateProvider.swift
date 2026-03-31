import Foundation

enum WeekDateProvider {
    static func currentWeekDates(calendar: Calendar = .current, referenceDate: Date = .now) -> [Date] {
        let start = calendar.dateInterval(of: .weekOfYear, for: referenceDate)?.start ?? referenceDate
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: start)
        }
    }
}
