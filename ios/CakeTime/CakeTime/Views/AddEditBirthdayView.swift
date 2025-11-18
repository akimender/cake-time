import SwiftUI

// Form view for adding or editing a birthday
struct AddEditBirthdayView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var birthdayManager: BirthdayManager
    
    let birthday: Birthday?
    
    @State private var name: String
    @State private var birthDate: Date
    @FocusState private var isNameFocused: Bool
    
    init(birthdayManager: BirthdayManager, birthday: Birthday? = nil) {
        self.birthdayManager = birthdayManager
        self.birthday = birthday
        
        // Initialize form fields with existing data if editing
        if let birthday = birthday {
            _name = State(initialValue: birthday.name)
            _birthDate = State(initialValue: birthday.birthDate)
        } else {
            _name = State(initialValue: "")
            _birthDate = State(initialValue: Date())
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
                
                Form {
                    Section {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.purple)
                            TextField("Name", text: $name)
                                .focused($isNameFocused)
                        }
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                            DatePicker("Birth Date", selection: $birthDate, displayedComponents: .date)
                        }
                    } header: {
                        Text("Birthday Information")
                    } footer: {
                        if let existingBirthday = birthday {
                            Text("Editing \(existingBirthday.name)'s birthday")
                                .font(.caption)
                        } else {
                            Text("Add a new birthday to track")
                                .font(.caption)
                        }
                    }
                    
                    // Custom preview card
                    if !name.isEmpty {
                        Section {
                            BirthdayPreviewCard(name: name, birthDate: birthDate)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(birthday == nil ? "Add Birthday" : "Edit Birthday")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveBirthday()
                    }
                    .disabled(name.isEmpty)
                    .fontWeight(.semibold)
                    .foregroundColor(name.isEmpty ? .secondary : .purple)
                }
            }
            .onAppear {
                isNameFocused = true
            }
        }
    }
    
    private func saveBirthday() {
        if let existingBirthday = birthday {
            // Update existing birthday
            let updatedBirthday = Birthday(
                id: existingBirthday.id,
                name: name,
                birthDate: birthDate
            )
            birthdayManager.updateBirthday(updatedBirthday)
        } else {
            // Add new birthday
            let newBirthday = Birthday(name: name, birthDate: birthDate)
            birthdayManager.addBirthday(newBirthday)
        }
        dismiss()
    }
}

// Preview card that shows how the birthday will look
struct BirthdayPreviewCard: View {
    let name: String
    let birthDate: Date
    
    private var daysUntil: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let birthComponents = calendar.dateComponents([.month, .day], from: birthDate)
        
        guard let month = birthComponents.month, let day = birthComponents.day else {
            return 365
        }
        
        let currentYear = calendar.component(.year, from: today)
        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        dateComponents.month = month
        dateComponents.day = day
        
        var nextDate = calendar.date(from: dateComponents)
        
        if nextDate == nil {
            dateComponents.year = currentYear + 1
            nextDate = calendar.date(from: dateComponents)
        }
        
        guard let date = nextDate else {
            return 365
        }
        
        var finalDate = date
        if date < today {
            dateComponents.year = currentYear + 1
            if let nextYearDate = calendar.date(from: dateComponents) {
                finalDate = nextYearDate
            }
        }
        
        return calendar.dateComponents([.day], from: today, to: finalDate).day ?? 365
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Birthday icon with gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: daysUntil == 0 
                                ? [.orange, .pink] 
                                : [.purple.opacity(0.6), .blue.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Text(birthdayEmoji(for: daysUntil))
                    .font(.system(size: 28))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(birthDate, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if daysUntil <= 30 {
                    HStack(spacing: 4) {
                        Image(systemName: daysUntil == 0 ? "sparkles" : "clock.fill")
                            .font(.caption)
                        Text(countdownText)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(daysUntil == 0 ? .orange : .blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill((daysUntil == 0 ? Color.orange : Color.blue).opacity(0.15))
                    )
                }
            }
            
            Spacer()
            
            // Days until badge
            VStack {
                Text("\(daysUntil)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                Text(daysUntil == 1 ? "day" : "days")
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
        .padding(.vertical, 8)
    }
    
    private var countdownText: String {
        if daysUntil == 0 {
            return "Today! 🎉"
        } else if daysUntil == 1 {
            return "Tomorrow"
        } else {
            return "\(daysUntil) days"
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
    AddEditBirthdayView(birthdayManager: BirthdayManager())
}
