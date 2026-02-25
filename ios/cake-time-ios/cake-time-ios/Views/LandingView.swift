//
//  LandingView.swift
//  cake-time-ios
//

import SwiftUI

struct LandingView: View {
    @Binding var showLogin: Bool
    @Binding var showRegister: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Brand
            VStack(spacing: 12) {
                Text("🎂")
                    .font(.system(size: 56))
                Text("CakeTime")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.text)
            }
            .padding(.bottom, 48)

            // Actions
            VStack(spacing: 16) {
                Button {
                    showRegister = true
                } label: {
                    Text("Create account")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radius))
                }
                .padding(.horizontal, 24)

                Button {
                    showLogin = true
                } label: {
                    Text("Log in")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.accent)
                }
                .padding(.top, 4)
            }

            Spacer()

            Text("© \(Calendar.current.component(.year, from: Date())) CakeTime")
                .font(.caption)
                .foregroundColor(Theme.textMuted)
                .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background)
    }
}
