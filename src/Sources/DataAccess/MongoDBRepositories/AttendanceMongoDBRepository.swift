//
//  AttendanceRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 18.04.2025.
//

import Fluent
import Vapor
import Domain

public final class AttendanceMongoDBRepository {
    private let db: Database

    public init(db: Database) {
        self.db = db
    }
}

// MARK: - IAttendanceRepository

extension AttendanceMongoDBRepository: IAttendanceRepository {
    public func create(_ attendance: Attendance) async throws {
        try await AttendanceMongoDBDTO(from: attendance).create(on: db)
    }

    public func update(_ attendance: Attendance) async throws {
        guard
            let existing = try await AttendanceMongoDBDTO.find(
                attendance.id,
                on: db
            )
        else { throw AttendanceError.attendanceNotFound }

        existing.trainingId = attendance.trainingId
        existing.membershipId = attendance.membershipId
        existing.status = attendance.status.rawValue

        try await existing.update(on: db)
    }

    public func find(id: UUID) async throws -> Attendance? {
        try await AttendanceMongoDBDTO.find(
            id,
            on: db
        )?.toAttendance()
    }

    public func find(membershipId: UUID) async throws -> [Attendance] {
        try await AttendanceMongoDBDTO.query(
            on: db
        ).filter(
            \.$membershipId == membershipId
        ).all().compactMap { $0.toAttendance() }
    }

    public func find(trainingId: UUID) async throws -> [Attendance] {
        try await AttendanceMongoDBDTO.query(
            on: db
        ).filter(
            \.$trainingId == trainingId
        ).all().compactMap { $0.toAttendance() }
    }

    public func findAll() async throws -> [Attendance] {
        try await AttendanceMongoDBDTO.query(
            on: db
        ).all().compactMap { $0.toAttendance() }
    }

    public func delete(id: UUID) async throws {
        guard
            let attendance = try await AttendanceMongoDBDTO.find(
                id,
                on: db
            )
        else {
            throw AttendanceError.attendanceNotFound
        }

        try await attendance.delete(on: db)
    }
}
