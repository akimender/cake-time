import Foundation
import SwiftUI

struct Birthday: Identifiable, Codable {
    var id: UUID
    var name: String
    var birthDate: Date
    
    init(id: UUID = UUID(), name: String, birthDate: Date) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
    }
    
    // Calculates the next occurrence of this birthday, handling edge cases like leap years
    var nextOccurrence: Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let birthComponents = calendar.dateComponents([.month, .day], from: birthDate)
        
        guard let month = birthComponents.month, let day = birthComponents.day else {
            return today
        }
        
        let currentYear = calendar.component(.year, from: today)
        
        // Try to create date for this year
        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        dateComponents.month = month
        dateComponents.day = day
        
        var nextDate = calendar.date(from: dateComponents)
        
        // Handle leap year edge case: if Feb 29 doesn't exist this year, try next year
        if nextDate == nil {
            dateComponents.year = currentYear + 1
            nextDate = calendar.date(from: dateComponents)
        }
        
        guard var date = nextDate else {
            return today
        }
        
        // If birthday has already passed this year, move to next year
        if date < today {
            dateComponents.year = currentYear + 1
            if let nextYearDate = calendar.date(from: dateComponents) {
                date = nextYearDate
            }
        }
        
        return date
    }
    
    // Number of days until the next birthday occurrence
    var daysUntil: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let next = calendar.startOfDay(for: nextOccurrence)
        return calendar.dateComponents([.day], from: today, to: next).day ?? 0
    }
    
    // Age the person will be on their next birthday
    var ageOnNextBirthday: Int {
        let calendar = Calendar.current
        let birthYear = calendar.component(.year, from: birthDate)
        let nextYear = calendar.component(.year, from: nextOccurrence)
        return nextYear - birthYear
    }
}
