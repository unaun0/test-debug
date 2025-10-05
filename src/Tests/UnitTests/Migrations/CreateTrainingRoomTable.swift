//
//  CreateTrainingRoomTable.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 07.09.2025.
//

import Fluent

struct CreateTrainingRoomTable: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("TrainingRoom")
            .id()
            .field("name", .string, .required)
            .field("capacity", .int, .required)
            .unique(on: "name")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("TrainingRoom").delete()
    }
}
