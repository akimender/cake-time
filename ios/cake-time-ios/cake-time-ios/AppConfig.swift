//
//  AppConfig.swift
//  cake-time-ios
//

import Foundation

enum AppConfig {
    /// Base URL for the CakeTime backend. Use your machine's IP for simulator (e.g. http://192.168.1.x:8000) or localhost for device with same machine.
    static var apiBaseURL: String {
        #if DEBUG
        return ProcessInfo.processInfo.environment["CAKETIME_API_BASE"] ?? "http://localhost:8000"
        #else
        return ProcessInfo.processInfo.environment["CAKETIME_API_BASE"] ?? "https://your-production-api.com"
        #endif
    }

    static var apiURL: URL? { URL(string: apiBaseURL) }
}
