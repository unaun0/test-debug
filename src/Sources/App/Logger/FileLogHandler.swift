//
//  FileLogHandler.swift
//  Backend
//
//  Created by Цховребова Яна on 12.05.2025.
//

import Foundation
import Logging

final class FileLogHandler: LogHandler, @unchecked Sendable {
    private let label: String
    private let fileHandle: FileHandle
    internal var logLevel: Logger.Level
    internal var metadata: Logger.Metadata = [:]

    init(label: String, logLevel: Logger.Level = .info, filePath: String) throws
    {
        self.label = label
        self.logLevel = logLevel

        let fileURL = URL(fileURLWithPath: filePath)
        if !FileManager.default.fileExists(atPath: filePath) {
            FileManager.default.createFile(atPath: filePath, contents: nil)
        }
        self.fileHandle = try FileHandle(forWritingTo: fileURL)
        self.fileHandle.seekToEndOfFile()
    }

    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }

    var logLevelGetter: Logger.Level {
        get { logLevel }
        set { logLevel = newValue }
    }

    var metadataGetter: Logger.Metadata {
        get { metadata }
        set { metadata = newValue }
    }

    func log(
        level: Logger.Level, message: Logger.Message,
        metadata: Logger.Metadata?, source: String, file: String,
        function: String, line: UInt
    ) {
        guard level >= self.logLevel else { return }

        let timestamp = ISO8601DateFormatter().string(from: Date())
        let meta =
            (metadata ?? self.metadata).isEmpty
            ? "" : " \(metadata ?? self.metadata)"
        let logMessage = "[\(timestamp)] [\(level)] \(message)\(meta)\n"

        if let data = logMessage.data(using: .utf8) {
            fileHandle.write(data)
        }
    }

    deinit {
        try? fileHandle.close()
    }
}
