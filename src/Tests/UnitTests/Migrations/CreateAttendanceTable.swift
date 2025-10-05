//
//  CreateAttendanceTable.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 07.09.2025.
//

import Fluent

struct CreateAttendanceTable: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("Attendance")
            .id()
            .field("membership_id", .uuid, .required)
            .field("training_id", .uuid, .required)
            .field("status", .string, .required)
            .unique(on: "membership_id", "training_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("Attendance").delete()
    }
}
