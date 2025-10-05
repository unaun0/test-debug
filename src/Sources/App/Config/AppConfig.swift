//  AppConfig.swift
//  Backend
//
//  Created by Цховребова Яна on 12.05.2025.
//

import Vapor

struct AppConfig: Content {
    struct DatabaseConfig: Content {
        let hostname: String
        let port: Int
        let username: String
        let password: String
        let databaseName: String
    }

    struct JWTConfig: Content {
        let secretKey: String
        let expirationTime: Int
    }

    struct LoggingConfig: Content {
        let logFilePath: String
        let logLevel: String
    }

    let database: [String: DatabaseConfig]
    let jwt: JWTConfig
    let logging: LoggingConfig

    func databaseConfig(for environment: Environment) -> DatabaseConfig {
        if environment == .testing {
            return database["test"] ?? database["default"]!
        } else {
            return database["default"]!
        }
    }
}

struct AppConfigKey: StorageKey {
    typealias Value = AppConfig
}

