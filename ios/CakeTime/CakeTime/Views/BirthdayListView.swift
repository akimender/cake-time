import SwiftUI

struct BirthdayListView: View {
    @StateObject private var birthdayManager = BirthdayManager()
    @State private var showingAddBirthday = false
    @State private var selectedBirthday: Birthday?
    
    // Sort birthdays by most upcoming (daysUntil)
    private var sortedBirthdays: [Birthday] {
        birthdayManager.birthdays.sorted { first, second in
            first.daysUntil < second.daysUntil
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [Color.purple.opacity(0.1), Color.pink.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if birthdayManager.birthdays.isEmpty {
                    EmptyStateView {
                        showingAddBirthday = true
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Upcoming birthdays section
                            if !birthdayManager.upcomingBirthdays.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "calendar.badge.clock")
                                            .foregroundColor(.purple)
                                            .font(.title2)
                                        Text("Upcoming")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                    }
                                    .padding(.horizontal)
                                    
                                    ForEach(birthdayManager.upcomingBirthdays) { birthday in
                                        BirthdayCardView(birthday: birthday)
                                            .onTapGesture {
                                                selectedBirthday = birthday
                                            }
                                    }
                                }
                                .padding(.top)
                            }
                            
                            // All birthdays section - sorted by most upcoming
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "person.2.fill")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                    Text("All Birthdays")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                .padding(.horizontal)
                                
                                ForEach(sortedBirthdays) { birthday in
                                    BirthdayCardView(birthday: birthday)
                                        .onTapGesture {
                                            selectedBirthday = birthday
                                        }
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                birthdayManager.deleteBirthday(birthday)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("🎂 CakeTime")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddBirthday = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.purple)
                    }
                }
            }
            .sheet(isPresented: $showingAddBirthday) {
                AddEditBirthdayView(birthdayManager: birthdayManager)
            }
            .sheet(item: $selectedBirthday) { birthday in
                AddEditBirthdayView(birthdayManager: birthdayManager, birthday: birthday)
            }
        }
    }
}

// Empty state view when no birthdays are added
struct EmptyStateView: View {
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "gift.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("No Birthdays Yet")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Add your first birthday reminder\nto get started!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                onAdd()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Birthday")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: 200)
                .background(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
            }
            .padding(.top)
        }
        .padding()
    }
}

// Card view for displaying a birthday
struct BirthdayCardView: View {
    let birthday: Birthday
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Birthday icon with gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: birthday.daysUntil == 0 
                                ? [.orange, .pink] 
                                : [.purple.opacity(0.6), .blue.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Text(birthdayEmoji(for: birthday.daysUntil))
                    .font(.system(size: 28))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(birthday.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(birthday.birthDate, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if birthday.daysUntil <= 30 {
                    HStack(spacing: 4) {
                        Image(systemName: birthday.daysUntil == 0 ? "sparkles" : "clock.fill")
                            .font(.caption)
                        Text(countdownText)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(birthday.daysUntil == 0 ? .orange : .blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill((birthday.daysUntil == 0 ? Color.orange : Color.blue).opacity(0.15))
                    )
                }
            }
            
            Spacer()
            
            // Days until badge
            VStack {
                Text("\(birthday.daysUntil)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                Text(birthday.daysUntil == 1 ? "day" : "days")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(8)
            .background(Color.purple.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3), value: isPressed)
    }
    
    private var countdownText: String {
        if birthday.daysUntil == 0 {
            return "Today! 🎉"
        } else if birthday.daysUntil == 1 {
            return "Tomorrow"
        } else {
            return "\(birthday.daysUntil) days"
        }
    }
    
    private func birthdayEmoji(for days: Int) -> String {
        if days == 0 {
            return "🎂"
        } else if days <= 7 {
            return "🎈"
        } else if days <= 30 {
            return "🎁"
        } else {
            return "🎊"
        }
    }
}

#Preview {
    BirthdayListView()
}
