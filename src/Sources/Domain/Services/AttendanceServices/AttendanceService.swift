//
//  AttendanceService.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Fluent
import Vapor

public final class AttendanceService: IAttendanceService {
    private let repository: IAttendanceRepository

    public init(repository: IAttendanceRepository) {
        self.repository = repository
    }

    public func create(_ data: AttendanceCreateDTO) async throws -> Attendance? {
        let attendances = try await repository.find(
            trainingId: data.trainingId
        ).filter { $0.membershipId == data.membershipId }
        if attendances.count != 0 {
            throw AttendanceError.invalidMembershipTrainingUnique
        }
        let attendance = Attendance(
            id: UUID(),
            membershipId: data.membershipId,
            trainingId: data.trainingId,
            status: data.status
        )
        try await repository.create(attendance)
        return attendance
    }
    
    public func update(id: UUID, with data: AttendanceUpdateDTO) async throws -> Attendance? {
        guard let attendance = try await repository.find(id: id)
        else { throw AttendanceError.attendanceNotFound }
        var trainingChanged = false
        var membershipChanged = false
        if let training = data.trainingId {
            attendance.trainingId = training
            trainingChanged = true
        }
        if let membership = data.membershipId {
            attendance.membershipId = membership
            membershipChanged = true
        }
        if membershipChanged || trainingChanged {
            let attendances = try await repository.find(
                trainingId: attendance.trainingId
            ).filter { $0.id != attendance.id }
                .filter { $0.membershipId == attendance.membershipId }
            if attendances.count != 0 {
                throw AttendanceError.invalidMembershipTrainingUnique
            }
        }
        if let status = data.status {
            attendance.status = status
        }
        try await repository.update(attendance)
        
        return attendance
    }

    public func find(id: UUID) async throws -> Attendance? {
        return try await repository.find(id: id)
    }

    public func find(trainingId: UUID) async throws -> [Attendance] {
        return try await repository.find(trainingId: trainingId)
    }

    public func find(membershipId: UUID) async throws -> [Attendance] {
        return try await repository.find(membershipId: membershipId)
    }

    public func findAll() async throws -> [Attendance] {
        return try await repository.findAll()
    }

    public func delete(id: UUID) async throws {
        guard let _ = try await repository.find(id: id) else {
            throw AttendanceError.attendanceNotFound
        }
        try await repository.delete(id: id)
    }
}
