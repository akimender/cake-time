//
//  ContentView.swift
//  cake-time-ios
//

import SwiftUI

struct ContentView: View {
    @StateObject private var auth = AuthService.shared
    @State private var showLogin = false
    @State private var showRegister = false

    var body: some View {
        Group {
            if auth.isLoggedIn {
                HomeView(auth: auth)
            } else {
                LandingView(showLogin: $showLogin, showRegister: $showRegister)
            }
        }
        .fullScreenCover(isPresented: $showLogin) {
            LoginView(auth: auth)
                .onDisappear { showLogin = false }
        }
        .fullScreenCover(isPresented: $showRegister) {
            RegisterView(auth: auth, onDismiss: {
                showRegister = false
            }, onRegisterSuccess: {
                showRegister = false
                showLogin = true
            })
        }
    }
}

#Preview {
    ContentView()
}
