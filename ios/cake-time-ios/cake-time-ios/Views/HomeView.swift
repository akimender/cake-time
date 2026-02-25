//
//  HomeView.swift
//  cake-time-ios
//

import SwiftUI


struct HomeView: View {
    @ObservedObject var auth: AuthService
    private let birthdayService = BirthdayService()

    @State private var birthdays: [Birthday] = []
    @State private var loading = true
    @State private var error: String?
    @State private var addPresented = false
    @State private var editing: Birthday?
    @State private var deleting: Birthday?
    @State private var submitError: String?

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Home")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.text)
                    Text("Welcome, \(auth.username ?? "there"). Manage your birthday list below.")
                        .font(.subheadline)
                        .foregroundColor(Theme.textMuted)

                    Button {
                        submitError = nil
                        addPresented = true
                    } label: {
                        Text("+ Add Birthday")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Theme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.radius))
                    }
                    .padding(.top, 4)

                    if loading {
                        Text("Loading…")
                            .foregroundColor(Theme.textMuted)
                            .padding(.vertical, 20)
                    } else if let err = error {
                        Text(err)
                            .foregroundColor(Theme.errorRed)
                            .font(.subheadline)
                            .padding(.vertical, 8)
                    } else if birthdays.isEmpty {
                        Text("No birthdays yet. Add one above.")
                            .foregroundColor(Theme.textMuted)
                            .padding(.vertical, 20)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(birthdays) { b in
                                birthdayRow(b)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
            }
            .background(Theme.background)

            footer
        }
        .background(Theme.surface)
        .task { await loadBirthdays() }
        .refreshable { await loadBirthdays() }
        .sheet(isPresented: $addPresented) {
            BirthdayFormSheet(
                title: "Add Birthday",
                submitLabel: "Add",
                initial: .empty,
                onSubmit: { name, day, month, year, notes in
                    try await birthdayService.create(name: name, birthDay: day, birthMonth: month, birthYear: year, notes: notes)
                },
                onCancel: { addPresented = false },
                onSuccess: {
                    addPresented = false
                    Task { await loadBirthdays() }
                }
            )
        }
        .sheet(item: $editing) { b in
            BirthdayFormSheet(
                title: "Edit Birthday",
                submitLabel: "Save",
                initial: .birthday(b),
                onSubmit: { name, day, month, year, notes in
                    try await birthdayService.update(id: b.id, name: name, birthDay: day, birthMonth: month, birthYear: year, notes: notes)
                },
                onCancel: { editing = nil },
                onSuccess: {
                    editing = nil
                    Task { await loadBirthdays() }
                }
            )
        }
        .alert("Delete birthday?", isPresented: Binding(
            get: { deleting != nil },
            set: { if !$0 { deleting = nil; submitError = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                deleting = nil
                submitError = nil
            }
            Button("Delete", role: .destructive) {
                if let b = deleting {
                    Task { await confirmDelete(b) }
                }
            }
        } message: {
            if let b = deleting {
                Text("Delete \(b.name)? This cannot be undone.")
            }
        }
    }

    private var header: some View {
        HStack {
            HStack(spacing: 8) {
                Text("🎂")
                    .font(.title2)
                Text("CakeTime")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.text)
            }
            Spacer()
            Button("Log out") {
                auth.logout()
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(Theme.textMuted)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Theme.background)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radius))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Theme.surface)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.black.opacity(0.08)),
            alignment: .bottom
        )
    }

    private func birthdayRow(_ b: Birthday) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(b.name)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.text)
                Text(BirthdayFormat.dateString(month: b.birthMonth, day: b.birthDay, year: b.birthYear))
                    .font(.subheadline)
                    .foregroundColor(Theme.textMuted)
                if let n = b.notes, !n.isEmpty {
                    Text(n)
                        .font(.caption)
                        .foregroundColor(Theme.textMuted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            HStack(spacing: 8) {
                Button("Edit") {
                    editing = b
                    submitError = nil
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Theme.text)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Theme.background)
                .clipShape(RoundedRectangle(cornerRadius: Theme.radius))
                Button("Delete") {
                    deleting = b
                    submitError = nil
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Theme.errorRed)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: Theme.radius))
            }
        }
        .padding(16)
        .cardStyle()
    }

    private var footer: some View {
        Text("© \(Calendar.current.component(.year, from: Date())) CakeTime")
            .font(.caption)
            .foregroundColor(Theme.textMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Theme.surface)
    }

    private func loadBirthdays() async {
        loading = true
        error = nil
        do {
            birthdays = try await birthdayService.list()
        } catch let e as APIError {
            error = e.localizedDescription
        } catch let err {
            error = err.localizedDescription
        }
        loading = false
    }

    private func confirmDelete(_ b: Birthday) async {
        do {
            try await birthdayService.delete(id: b.id)
            await MainActor.run {
                deleting = nil
                Task { await loadBirthdays() }
            }
        } catch {
            await MainActor.run {
                submitError = error.localizedDescription
            }
        }
    }
}
