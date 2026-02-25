//
//  BirthdayService.swift
//  cake-time-ios
//

import Foundation

struct BirthdayService {
    private let auth = AuthService.shared

    func list() async throws -> [Birthday] {
        guard let base = AppConfig.apiURL else { throw APIError.invalidURL }
        var request = URLRequest(url: base.appendingPathComponent("api/birthdays/"))
        request.httpMethod = "GET"
        let data = try await auth.authenticatedData(for: request)
        return try JSONDecoder().decode([Birthday].self, from: data)
    }

    func create(name: String, birthDay: Int, birthMonth: Int, birthYear: Int?, notes: String?) async throws -> Birthday {
        guard let base = AppConfig.apiURL else { throw APIError.invalidURL }
        var body: [String: Any] = [
            "name": name,
            "birth_day": birthDay,
            "birth_month": birthMonth,
        ]
        if let y = birthYear { body["birth_year"] = y }
        if let n = notes { body["notes"] = n }

        var request = URLRequest(url: base.appendingPathComponent("api/birthdays/create/"))
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let data = try await auth.authenticatedData(for: request)
        return try JSONDecoder().decode(Birthday.self, from: data)
    }

    func update(id: Int, name: String, birthDay: Int, birthMonth: Int, birthYear: Int?, notes: String?) async throws -> Birthday {
        guard let base = AppConfig.apiURL else { throw APIError.invalidURL }
        var body: [String: Any] = [
            "name": name,
            "birth_day": birthDay,
            "birth_month": birthMonth,
        ]
        if let y = birthYear { body["birth_year"] = y }
        if let n = notes { body["notes"] = n }

        var request = URLRequest(url: base.appendingPathComponent("api/birthdays/update/\(id)/"))
        request.httpMethod = "PATCH"
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let data = try await auth.authenticatedData(for: request)
        return try JSONDecoder().decode(Birthday.self, from: data)
    }

    func delete(id: Int) async throws {
        guard let base = AppConfig.apiURL else { throw APIError.invalidURL }
        var request = URLRequest(url: base.appendingPathComponent("api/birthdays/delete/\(id)/"))
        request.httpMethod = "DELETE"
        _ = try await auth.authenticatedData(for: request)
    }
}
