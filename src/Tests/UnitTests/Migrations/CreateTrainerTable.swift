//
//  CreateTrainerTable.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 07.09.2025.
//

import Fluent

struct CreateTrainerTable: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("Trainer")
            .id()
            .field("user_id", .uuid, .required)
            .field("description", .string, .required)
            .unique(on: "user_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("Trainer").delete()
    }
}
