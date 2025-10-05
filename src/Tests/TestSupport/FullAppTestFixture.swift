//
//  FullAppTestFixture.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 30.09.2025.
//

import Vapor
import Fluent

@testable import App

final class FullAppTestFixture {
    var app: Application!

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

        let configData = try Data(
            contentsOf: URL(fileURLWithPath: configPath)
        )
        let appConfig = try JSONDecoder().decode(
            AppConfig.self, from: configData
        )
        app.setAppConfig(appConfig)
        
        app.http.server.configuration.hostname = "127.0.0.1"
        app.http.server.configuration.port = 8010

        try await configure(app)
        
        try await app.startup()
    }

    func shutdown() async throws {
        try await app.asyncShutdown()
        app = nil
    }
}
