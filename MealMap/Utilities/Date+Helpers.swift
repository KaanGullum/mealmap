import Foundation

extension Date {
    func isWithinUpcoming(days: Int, calendar: Calendar = .current) -> Bool {
        guard days >= 0 else {
            return false
        }

        let startOfToday = calendar.startOfDay(for: .now)
        let startOfTarget = calendar.startOfDay(for: self)

        guard startOfTarget >= startOfToday else {
            return false
        }

        let dayDifference = calendar.dateComponents([.day], from: startOfToday, to: startOfTarget).day ?? .max
        return dayDifference <= days
    }

    var dayMonthText: String {
        formatted(.dateTime.day().month(.abbreviated))
    }

    var weekdayText: String {
        formatted(.dateTime.weekday(.wide))
    }
}
