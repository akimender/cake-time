//
//  RegisterView.swift
//  cake-time-ios
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var auth: AuthService
    var onDismiss: () -> Void
    var onRegisterSuccess: () -> Void

    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errors: (username: String?, password: String?, confirmPassword: String?) = (nil, nil, nil)
    @State private var submitting = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Button("← Back to home") {
                        onDismiss()
                        dismiss()
                    }
                    .foregroundColor(Theme.accent)
                    .font(.subheadline)

                    Text("Create your account")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.text)
                    Text("Use your new account to log in and manage birthdays.")
                        .font(.subheadline)
                        .foregroundColor(Theme.textMuted)

                    VStack(alignment: .leading, spacing: 16) {
                        field("Username", text: $username, error: errors.username, placeholder: "e.g. alex")
                            .autocapitalization(.none)
                        field("Email (optional)", text: $email, error: nil, placeholder: "you@example.com")
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        field("Password", text: $password, error: errors.password, placeholder: "At least 8 characters", secure: true)
                        field("Confirm password", text: $confirmPassword, error: errors.confirmPassword, placeholder: "Same as above", secure: true)

                        Button {
                            submit()
                        } label: {
                            Text(submitting ? "Creating account…" : "Create account")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .background(Theme.accent)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.radius))
                        }
                        .disabled(submitting)
                    }
                    .padding(.top, 8)

                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .foregroundColor(Theme.textMuted)
                        Button("Log in") {
                            onDismiss()
                            dismiss()
                        }
                        .foregroundColor(Theme.accent)
                    }
                    .font(.subheadline)
                    .padding(.top, 8)
                }
                .padding(24)
            }
            .background(Theme.background)
        }
    }

    private func field(_ label: String, text: Binding<String>, error: String?, placeholder: String, secure: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Theme.text)
            Group {
                if secure {
                    SecureField(placeholder, text: text)
                } else {
                    TextField(placeholder, text: text)
                }
            }
            .textFieldStyle(.plain)
            .padding(12)
            .background(Theme.background)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radius)
                    .stroke(error != nil ? Theme.errorRed : Color.black.opacity(0.12), lineWidth: 1)
            )
            if let e = error {
                Text(e)
                    .font(.caption)
                    .foregroundColor(Theme.errorRed)
            }
        }
    }

    private func submit() {
        errors = (nil, nil, nil)
        if username.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.username = "Required."
        }
        if password.isEmpty {
            errors.password = "Required."
        } else if password.count < 8 {
            errors.password = "Password must be at least 8 characters."
        }
        if password != confirmPassword {
            errors.confirmPassword = "Passwords do not match."
        }
        if errors.username != nil || errors.password != nil || errors.confirmPassword != nil { return }

        submitting = true
        Task {
            do {
                try await auth.register(
                    username: username.trimmingCharacters(in: .whitespaces),
                    email: email.isEmpty ? nil : email,
                    password: password
                )
                await MainActor.run {
                    onRegisterSuccess()
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    let msg = error.localizedDescription
                    errors.username = msg
                    errors.password = nil
                    errors.confirmPassword = nil
                }
            }
            await MainActor.run { submitting = false }
        }
    }
}
