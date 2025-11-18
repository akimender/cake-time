import Foundation
import SwiftUI

// Manages the list of birthdays with persistence and notification scheduling
@MainActor
class BirthdayManager: ObservableObject {
    @Published var birthdays: [Birthday] = []
    
    private let saveKey = "SavedBirthdays"
    
    init() {
        loadBirthdays()
    }
    
    func addBirthday(_ birthday: Birthday) {
        birthdays.append(birthday)
        saveBirthdays()
        // Automatically schedule notification for new birthday
        NotificationManager.shared.scheduleBirthdayNotification(for: birthday)
    }
    
    func updateBirthday(_ birthday: Birthday) {
        if let index = birthdays.firstIndex(where: { $0.id == birthday.id }) {
            let oldBirthday = birthdays[index]
            // Cancel old notification before updating
            NotificationManager.shared.cancelNotification(for: oldBirthday)
            birthdays[index] = birthday
            saveBirthdays()
            // Schedule new notification with updated date
            NotificationManager.shared.scheduleBirthdayNotification(for: birthday)
        }
    }
    
    func deleteBirthday(_ birthday: Birthday) {
        // Clean up notification when birthday is deleted
        NotificationManager.shared.cancelNotification(for: birthday)
        birthdays.removeAll { $0.id == birthday.id }
        saveBirthdays()
    }
    
    func deleteBirthday(at offsets: IndexSet) {
        let birthdaysToDelete = offsets.map { birthdays[$0] }
        for birthday in birthdaysToDelete {
            NotificationManager.shared.cancelNotification(for: birthday)
        }
        birthdays.remove(atOffsets: offsets)
        saveBirthdays()
    }
    
    // Returns birthdays happening in the next 30 days, sorted by days until
    var upcomingBirthdays: [Birthday] {
        birthdays.filter { $0.daysUntil <= 30 }
            .sorted { $0.daysUntil < $1.daysUntil }
    }
    
    // Persist birthdays to UserDefaults
    private func saveBirthdays() {
        if let encoded = try? JSONEncoder().encode(birthdays) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    // Load birthdays from UserDefaults and reschedule notifications
    private func loadBirthdays() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Birthday].self, from: data) {
            birthdays = decoded
            // Reschedule all notifications when app loads
            NotificationManager.shared.rescheduleAllNotifications(for: birthdays)
        }
    }
}
