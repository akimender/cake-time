//
//  BirthdayFormSheet.swift
//  cake-time-ios
//

import SwiftUI

struct BirthdayFormSheet: View {
    let title: String
    let submitLabel: String
    let initial: BirthdayFormInitial
    let onSubmit: (String, Int, Int, Int?, String?) async throws -> Void
    let onCancel: () -> Void
    let onSuccess: () -> Void

    @State private var name = ""
    @State private var day = 1
    @State private var month = 1
    @State private var yearText = ""
    @State private var notes = ""
    @State private var submitError: String?
    @State private var submitting = false

    enum BirthdayFormInitial {
        case empty
        case birthday(Birthday)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Name")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Theme.text)
                        TextField("Name", text: $name)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Theme.background)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.radius))
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.radius)
                                    .stroke(Color.black.opacity(0.12), lineWidth: 1)
                            )
                    }
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Month")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Theme.text)
                            Picker("Month", selection: $month) {
                                ForEach(1...12, id: \.self) { i in
                                    Text(BirthdayFormat.monthNames[i - 1]).tag(i)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(10)
                            .background(Theme.background)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.radius))
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Day")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Theme.text)
                            Picker("Day", selection: $day) {
                                ForEach(1...31, id: \.self) { i in
                                    Text("\(i)").tag(i)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(10)
                            .background(Theme.background)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.radius))
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Year (optional)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Theme.text)
                            TextField("e.g. 1990", text: $yearText)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.plain)
                                .padding(12)
                                .background(Theme.background)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.radius))
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.radius)
                                        .stroke(Color.black.opacity(0.12), lineWidth: 1)
                                )
                        }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Notes (optional)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Theme.text)
                        TextField("Notes", text: $notes, axis: .vertical)
                            .lineLimit(2...6)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Theme.background)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.radius))
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.radius)
                                    .stroke(Color.black.opacity(0.12), lineWidth: 1)
                            )
                    }
                    if let err = submitError {
                        Text(err)
                            .font(.caption)
                            .foregroundColor(Theme.errorRed)
                    }
                    HStack(spacing: 12) {
                        Spacer()
                        Button("Cancel") {
                            onCancel()
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.text)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Theme.background)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radius))
                        Button(submitLabel) {
                            submit()
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radius))
                        .disabled(submitting)
                    }
                    .padding(.top, 8)
                }
                .padding(24)
            }
            .background(Theme.surface)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { fillFromInitial() }
        }
    }

    private func fillFromInitial() {
        switch initial {
        case .empty:
            name = ""
            day = 1
            month = 1
            yearText = ""
            notes = ""
        case .birthday(let b):
            name = b.name
            day = b.birthDay
            month = b.birthMonth
            yearText = b.birthYear.map { "\($0)" } ?? ""
            notes = b.notes ?? ""
        }
    }

    private func submit() {
        submitError = nil
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        if trimmedName.isEmpty {
            submitError = "Name is required."
            return
        }
        let year: Int? = yearText.isEmpty ? nil : Int(yearText)
        submitting = true
        Task {
            do {
                try await onSubmit(trimmedName, day, month, year, notes.isEmpty ? nil : notes)
                await MainActor.run {
                    onSuccess()
                }
            } catch {
                await MainActor.run {
                    submitError = error.localizedDescription
                }
            }
            await MainActor.run { submitting = false }
        }
    }
}
