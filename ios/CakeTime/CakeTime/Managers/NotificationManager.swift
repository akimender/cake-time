import Foundation
import UserNotifications

// Singleton manager for handling birthday notification scheduling
class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // Request notification permissions from the user
    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }
    
    // Schedule a notification for 9 AM on the birthday
    func scheduleBirthdayNotification(for birthday: Birthday) {
        let content = UNMutableNotificationContent()
        content.title = "🎉 Birthday Reminder"
        content.body = "It's \(birthday.name)'s birthday today! They're turning \(birthday.ageOnNextBirthday)."
        content.sound = .default
        content.badge = 1
        
        let calendar = Calendar.current
        var nextOccurrence = birthday.nextOccurrence
        let now = Date()
        
        // If it's already past 9 AM on the birthday, schedule for next year instead
        if calendar.isDate(nextOccurrence, inSameDayAs: now) {
            let hour = calendar.component(.hour, from: now)
            if hour >= 9 {
                if let nextYear = calendar.date(byAdding: .year, value: 1, to: nextOccurrence) {
                    nextOccurrence = nextYear
                }
            }
        }
        
        // Schedule for 9 AM on the birthday
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: nextOccurrence)
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        // Only schedule if the date is in the future
        if let triggerDate = calendar.date(from: dateComponents), triggerDate > now {
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(
                identifier: birthday.id.uuidString,
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }
    
    func cancelNotification(for birthday: Birthday) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [birthday.id.uuidString])
    }
    
    // Reschedule all notifications (useful when app launches to ensure they're up to date)
    func rescheduleAllNotifications(for birthdays: [Birthday]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        for birthday in birthdays {
            scheduleBirthdayNotification(for: birthday)
        }
    }
}
