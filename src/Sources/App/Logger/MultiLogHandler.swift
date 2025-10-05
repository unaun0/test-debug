//
//  MultiLogHandler.swift
//  Backend
//
//  Created by Цховребова Яна on 12.05.2025.
//

import Logging

final class MultiLogHandler: LogHandler, @unchecked Sendable {
    private var terminalHandler: LogHandler
    private var fileHandler: LogHandler

    init(terminalHandler: LogHandler, fileHandler: LogHandler) {
        self.terminalHandler = terminalHandler
        self.fileHandler = fileHandler
    }

    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { terminalHandler[metadataKey: key] }
        set {
            terminalHandler[metadataKey: key] = newValue
            fileHandler[metadataKey: key] = newValue
        }
    }

    var logLevel: Logger.Level {
        get { terminalHandler.logLevel }
        set {
            terminalHandler.logLevel = newValue
            fileHandler.logLevel = newValue
        }
    }

    var metadata: Logger.Metadata {
        get { terminalHandler.metadata }
        set {
            terminalHandler.metadata = newValue
            fileHandler.metadata = newValue
        }
    }

    func log(
        level: Logger.Level, message: Logger.Message,
        metadata: Logger.Metadata?, source: String, file: String,
        function: String, line: UInt
    ) {
        terminalHandler.log(
            level: level, message: message, metadata: metadata, source: source,
            file: file, function: function, line: line)
        fileHandler.log(
            level: level, message: message, metadata: metadata, source: source,
            file: file, function: function, line: line)
    }
}
