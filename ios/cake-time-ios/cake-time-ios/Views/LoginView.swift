//
//  LoginView.swift
//  cake-time-ios
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var auth: AuthService

    @State private var username = ""
    @State private var password = ""
    @State private var errors: (username: String?, password: String?) = (nil, nil)
    @State private var submitting = false
    @State private var showRegister = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Button("← Back to home") {
                    dismiss()
                }
                .foregroundColor(Theme.accent)
                .font(.subheadline)

                Text("Log in")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.text)
                Text("Use your CakeTime account to continue.")
                    .font(.subheadline)
                    .foregroundColor(Theme.textMuted)

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Username")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Theme.text)
                        TextField("Your username", text: $username)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Theme.background)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.radius))
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.radius)
                                    .stroke(errors.username != nil ? Theme.errorRed : Color.black.opacity(0.12), lineWidth: 1)
                            )
                            .autocapitalization(.none)
                        if let e = errors.username {
                            Text(e)
                                .font(.caption)
                                .foregroundColor(Theme.errorRed)
                        }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Theme.text)
                        SecureField("Your password", text: $password)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Theme.background)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.radius))
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.radius)
                                    .stroke(errors.password != nil ? Theme.errorRed : Color.black.opacity(0.12), lineWidth: 1)
                            )
                        if let e = errors.password {
                            Text(e)
                                .font(.caption)
                                .foregroundColor(Theme.errorRed)
                        }
                    }
                    Button {
                        submit()
                    } label: {
                        Text(submitting ? "Logging in…" : "Log in")
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
                    Text("Don't have an account?")
                        .foregroundColor(Theme.textMuted)
                    Button("Get started") {
                        showRegister = true
                    }
                    .foregroundColor(Theme.accent)
                }
                .font(.subheadline)
                .padding(.top, 8)
            }
            .padding(24)
        }
        .background(Theme.background)
        .fullScreenCover(isPresented: $showRegister) {
            RegisterView(auth: auth, onDismiss: { showRegister = false }, onRegisterSuccess: { showRegister = false })
        }
    }

    private func submit() {
        errors = (nil, nil)
        if username.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.username = "Required."
        }
        if password.isEmpty {
            errors.password = "Required."
        }
        if errors.username != nil || errors.password != nil { return }

        submitting = true
        Task {
            do {
                try await auth.login(username: username.trimmingCharacters(in: .whitespaces), password: password)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    let msg = error.localizedDescription
                    errors.username = msg
                    errors.password = nil
                }
            }
            await MainActor.run { submitting = false }
        }
    }
}
