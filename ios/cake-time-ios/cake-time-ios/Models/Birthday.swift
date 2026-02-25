//
//  Birthday.swift
//  cake-time-ios
//

import Foundation

struct Birthday: Identifiable, Codable, Equatable {
    let id: Int
    var name: String
    var birthDay: Int
    var birthMonth: Int
    var birthYear: Int?
    var notes: String?

    enum CodingKeys: String, CodingKey {
        case id, name, notes
        case birthDay = "birth_day"
        case birthMonth = "birth_month"
        case birthYear = "birth_year"
    }
}

enum BirthdayFormat {
    static let monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    static func dateString(month: Int, day: Int, year: Int?) -> String {
        let m = (1...12).contains(month) ? monthNames[month - 1] : "\(month)"
        if let y = year { return "\(m) \(day), \(y)" }
        return "\(m) \(day)"
    }
}
