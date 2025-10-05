//
//  CreateMembershipTable.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 07.09.2025.
//

import Fluent

struct CreateMembershipTable: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("Membership")
            .id()
            .field("user_id", .uuid, .required)
            .field("membership_type_id", .uuid, .required)
            .field("start_date", .date)
            .field("end_date", .date)
            .field("available_sessions", .int, .required)
            .unique(on: "user_id", "membership_type_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("Membership").delete()
    }
}
