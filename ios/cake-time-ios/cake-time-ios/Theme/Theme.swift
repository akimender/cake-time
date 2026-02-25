//
//  Theme.swift
//  cake-time-ios
//

import SwiftUI

enum Theme {
    static let background = Color(red: 250/255, green: 249/255, blue: 251/255)
    static let surface = Color.white
    static let text = Color(red: 26/255, green: 26/255, blue: 31/255)
    static let textMuted = Color(red: 107/255, green: 107/255, blue: 118/255)
    static let accent = Color(red: 124/255, green: 58/255, blue: 237/255)
    static let accentHover = Color(red: 109/255, green: 40/255, blue: 217/255)
    static let accentSoft = Color(red: 237/255, green: 233/255, blue: 254/255)
    static let errorRed = Color(red: 220/255, green: 38/255, blue: 38/255)
    static let radius: CGFloat = 12
    static let radiusLg: CGFloat = 20
}

extension View {
    func cardStyle() -> some View {
        self
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radius)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
    }
}
