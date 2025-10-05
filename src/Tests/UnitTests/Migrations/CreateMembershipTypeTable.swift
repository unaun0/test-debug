//
//  CreateMembershipTypeTable.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 07.09.2025.
//

import Fluent

struct CreateMembershipTypeTable: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("MembershipType")
            .id()
            .field("name", .string, .required)
            .field("price", .double, .required)
            .field("sessions", .int, .required)
            .field("days", .int, .required)
            .unique(on: "name")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("MembershipType").delete()
    }
}
