//
//  TestAppFixture.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 17.09.2025.
//

import Vapor
import Fluent

@testable import App

final class TestAppFixture {
    var app: Application!
    var db: Database!

    init() async throws {
        app = try await Application.make(.testing)
        
        guard let configPath = Environment.get("CONFIG_PATH") else {
            fatalError("CONFIG_PATH not set in environment.")
        }
        app.setAppConfig(
            try JSONDecoder().decode(
                AppConfig.self,
                from: try Data(
                    contentsOf: URL(
                        fileURLWithPath: configPath
                    )
                )
            )
        )
        let dbConfig = app.appConfig.databaseConfig(for: app.environment)
        
        app.databases.use(
            .postgres(
                configuration: .init(
                    hostname: dbConfig.hostname,
                    port: dbConfig.port,
                    username: dbConfig.username,
                    password: dbConfig.password,
                    database: dbConfig.databaseName,
                    tls: .prefer(try .init(configuration: .clientDefault))
                )
            ),
            as: .psql
        )
        db = app.db(.psql)
    }

    func shutdown() async throws {
        try await app.asyncShutdown()
        db = nil
        app = nil
    }
}
