//
//  LoggingSystem.swift
//  Backend
//
//  Created by Цховребова Яна on 12.05.2025.
//

import Logging
import Vapor

extension LoggingSystem {
    @preconcurrency
    public static func bootstrap(
        from environment: inout Environment,
        label: String,
        logFilePath: String,
        logLevel: String
    ) throws {
        let level: Logger.Level
        switch logLevel.lowercased() {
        case "debug":
            level = .debug
        case "info":
            level = .info
        case "warning":
            level = .warning
        case "error":
            level = .error
        default:
            level = .debug
        }

        let terminalHandler = StreamLogHandler.standardOutput(label: label)
        let fileHandler = try FileLogHandler(
            label: label, logLevel: level, filePath: logFilePath)
        let multiHandler = MultiLogHandler(
            terminalHandler: terminalHandler, fileHandler: fileHandler)

        LoggingSystem.bootstrap { label in
            return multiHandler
        }
    }
}
