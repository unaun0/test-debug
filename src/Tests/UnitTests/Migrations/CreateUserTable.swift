//
//  CreateUserTable.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 07.09.2025.
//

import Fluent

struct CreateUserTable: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("User")
            .id()
            .field("email", .string, .required)
            .field("phone_number", .string, .required)
            .field("password", .string, .required)
            .field("first_name", .string, .required)
            .field("last_name", .string, .required)
            .field("gender", .string, .required)
            .field("birth_date", .date, .required)
            .field("role", .string, .required)
            .unique(on: "email")
            .unique(on: "phone_number")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("User").delete()
    }
}
