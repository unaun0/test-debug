//
//  AttendanceRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 18.04.2025.
//

import Fluent
import Vapor
import Domain

public final class AttendanceRepository {
    private let db: Database

    public init(db: Database) {
        self.db = db
    }
}

// MARK: - IAttendanceRepository

extension AttendanceRepository: IAttendanceRepository {
    public func create(_ attendance: Attendance) async throws {
        try await AttendanceDBDTO(from: attendance).create(on: db)
    }

    public func update(_ attendance: Attendance) async throws {
        guard
            let existing = try await AttendanceDBDTO.find(
                attendance.id,
                on: db
            )
        else {
            throw AttendanceRepositoryError.attendanceNotFound
        }

        existing.trainingId = attendance.trainingId
        existing.membershipId = attendance.membershipId
        existing.status = attendance.status.rawValue

        try await existing.update(on: db)
    }

    public func find(id: UUID) async throws -> Attendance? {
        try await AttendanceDBDTO.find(
            id,
            on: db
        )?.toAttendance()
    }

    public func find(membershipId: UUID) async throws -> [Attendance] {
        try await AttendanceDBDTO.query(
            on: db
        ).filter(
            \.$membershipId == membershipId
        ).all().compactMap { $0.toAttendance() }
    }

    public func find(trainingId: UUID) async throws -> [Attendance] {
        try await AttendanceDBDTO.query(
            on: db
        ).filter(
            \.$trainingId == trainingId
        ).all().compactMap { $0.toAttendance() }
    }

    public func findAll() async throws -> [Attendance] {
        try await AttendanceDBDTO.query(
            on: db
        ).all().compactMap { $0.toAttendance() }
    }

    public func delete(id: UUID) async throws {
        guard
            let attendance = try await AttendanceDBDTO.find(
                id,
                on: db
            )
        else {
            throw AttendanceRepositoryError.attendanceNotFound
        }

        try await attendance.delete(on: db)
    }
}

public enum AttendanceRepositoryError: Error, LocalizedError {
    case attendanceNotFound

    public var errorDescription: String? {
        switch self {
        case .attendanceNotFound:
            return "Посещение не найдено."
        }
    }
}
