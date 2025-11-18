import SwiftUI
import UserNotifications

@main
struct CakeTimeApp: App {
    @StateObject private var birthdayManager = BirthdayManager()
    
    init() {
        // Request notification permissions on app launch
        Task {
            await NotificationManager.shared.requestAuthorization()
        }
        
        // Customize navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.systemPurple]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.systemPurple]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            BirthdayListView()
                .environmentObject(birthdayManager)
        }
    }
}
