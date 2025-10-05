//
//  CreateTrainingTable.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 07.09.2025.
//

import Fluent

struct CreateTrainingTable: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("Training")
            .id()
            .field("date", .datetime, .required)
            .field("room_id", .uuid, .required)
            .field("trainer_id", .uuid, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("Training").delete()
    }
}
