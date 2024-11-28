import Foundation

extension Date {
    public func addWeek(week: Int) -> Date {
        return Calendar.current.date(byAdding: .weekOfYear, value: week, to: self) ?? Date()
    }
    
    public func addMonth(month: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: month, to: self) ?? Date()
    }
    
    public func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
    
    public func isToday() -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(self)
    }
}
