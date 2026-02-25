//
//  AuthService.swift
//  cake-time-ios
//

import Foundation
import Combine

final class AuthService: ObservableObject {
    static let shared = AuthService()

    private let storageKey = "cake_time_auth"
    private let defaults = UserDefaults.standard

    @Published private(set) var isLoggedIn = false
    @Published private(set) var username: String?

    private var accessToken: String?
    private var refreshToken: String?

    init() {
        loadFromStorage()
    }

    private func loadFromStorage() {
        guard let data = defaults.data(forKey: storageKey),
              let stored = try? JSONDecoder().decode(StoredAuth.self, from: data),
              !stored.refreshToken.isEmpty else {
            isLoggedIn = false
            username = nil
            accessToken = nil
            refreshToken = nil
            return
        }
        // Restore session; do not log out based on access token expiry. We will refresh when needed.
        accessToken = stored.accessToken
        refreshToken = stored.refreshToken
        username = stored.username
        isLoggedIn = true
    }

    private func isAccessTokenValid(_ token: String) -> Bool {
        let parts = token.split(separator: ".")
        guard parts.count >= 2 else { return false }
        var base64 = String(parts[1])
        base64 = base64.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64 += "=" }
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else { return false }
        return Date().timeIntervalSince1970 < exp - 60
    }

    private func clearStorage() {
        defaults.removeObject(forKey: storageKey)
        accessToken = nil
        refreshToken = nil
        username = nil
        isLoggedIn = false
    }

    private func saveToStorage(access: String, refresh: String, username: String?) {
        let stored = StoredAuth(accessToken: access, refreshToken: refresh, username: username)
        if let data = try? JSONEncoder().encode(stored) {
            defaults.set(data, forKey: storageKey)
        }
        accessToken = access
        refreshToken = refresh
        self.username = username
        isLoggedIn = true
    }

    var authHeader: (String, String)? {
        guard let token = accessToken else { return nil }
        return ("Authorization", "Bearer \(token)")
    }

    /// Returns a valid access token, refreshing if necessary. Only clears session if refresh fails (e.g. 401).
    private func ensureValidAccessToken() async throws -> String {
        if let access = accessToken, isAccessTokenValid(access) {
            return access
        }
        guard let refresh = refreshToken, !refresh.isEmpty else {
            clearStorage()
            throw APIError.unauthorized
        }
        try await refreshAccessToken()
        guard let access = accessToken else {
            clearStorage()
            throw APIError.unauthorized
        }
        return access
    }

    /// Refreshes the access token using the stored refresh token. Clears session on 401.
    private func refreshAccessToken() async throws {
        guard let base = AppConfig.apiURL else { throw APIError.invalidURL }
        guard let refresh = refreshToken else {
            clearStorage()
            throw APIError.unauthorized
        }
        let url = base.appendingPathComponent("api/token/refresh/")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["refresh": refresh])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { return }
        if http.statusCode == 401 {
            clearStorage()
            throw APIError.unauthorized
        }
        try checkResponse(response, data: data)

        // Backend returns {"access": "..."}; refresh token is only returned if ROTATE_REFRESH_TOKENS is on.
        let decoded = try JSONDecoder().decode(RefreshResponse.self, from: data)
        let currentRefresh = refreshToken ?? ""
        let currentUsername = username
        saveToStorage(access: decoded.access, refresh: currentRefresh, username: currentUsername)
    }

    // MARK: - API

    func login(username: String, password: String) async throws {
        guard let base = AppConfig.apiURL else { throw APIError.invalidURL }
        let url = base.appendingPathComponent("api/token/")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["username": username, "password": password])

        let (data, response) = try await URLSession.shared.data(for: request)
        try checkResponse(response, data: data)

        let decoded = try JSONDecoder().decode(TokenResponse.self, from: data)
        saveToStorage(access: decoded.access, refresh: decoded.refresh, username: username)
    }

    func register(username: String, email: String?, password: String) async throws {
        guard let base = AppConfig.apiURL else { throw APIError.invalidURL }
        let url = base.appendingPathComponent("api/register/")
        var body: [String: String] = ["username": username, "password": password]
        if let e = email, !e.isEmpty { body["email"] = e }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        try checkResponse(response, data: data)
    }

    func logout() {
        clearStorage()
    }

    /// Performs an authenticated request. Refreshes the access token if expired. Throws only if not logged in or request fails (or refresh fails).
    func authenticatedData(for request: URLRequest) async throws -> Data {
        let token = try await ensureValidAccessToken()
        var req = request
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        if req.value(forHTTPHeaderField: "Content-Type") == nil {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        var (data, response) = try await URLSession.shared.data(for: req)
        // If 401, try refresh once and retry (token may have expired between ensureValidAccessToken and response).
        if let http = response as? HTTPURLResponse, http.statusCode == 401, refreshToken != nil {
            try? await refreshAccessToken()
            if let newToken = accessToken {
                req.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
                (data, response) = try await URLSession.shared.data(for: req)
            }
        }
        try checkResponse(response, data: data)
        return data
    }

    private func checkResponse(_ response: URLResponse?, data: Data) throws {
        guard let http = response as? HTTPURLResponse else { return }
        if (200..<300).contains(http.statusCode) { return }
        let message = (try? JSONDecoder().decode(APIErrorBody.self, from: data)).flatMap { $0.error ?? $0.detail ?? $0.details?.values.first?.first }
        throw APIError.server(http.statusCode, message ?? "Request failed")
    }
}

private struct StoredAuth: Codable {
    let accessToken: String
    let refreshToken: String
    let username: String?
}

private struct TokenResponse: Codable {
    let access: String
    let refresh: String
}

/// Response from POST /api/token/refresh/ (returns only access by default).
private struct RefreshResponse: Codable {
    let access: String
}

struct APIErrorBody: Codable {
    let error: String?
    let detail: String?
    let details: [String: [String]]?
}

enum APIError: LocalizedError {
    case invalidURL
    case unauthorized
    case server(Int, String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL"
        case .unauthorized: return "Please log in again."
        case .server(_, let msg): return msg
        }
    }
}
