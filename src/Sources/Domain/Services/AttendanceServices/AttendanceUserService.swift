//
//  AttendanceUserService.swift
//  Backend
//
//  Created by Цховребова Яна on 12.05.2025.
//

import Vapor

public final class AttendanceUserService: IAttendanceUserService {
    private let attendanceService: IAttendanceService
    private let membershipService: IMembershipService
    private let trainingService: ITrainingService

    public init(
        attendanceService: IAttendanceService,
        membershipService: IMembershipService,
        trainingService: ITrainingService
    ) {
        self.attendanceService = attendanceService
        self.membershipService = membershipService
        self.trainingService = trainingService
    }

    public func getMyAttendances(userId: UUID) async throws -> [Attendance] {
        let membershipsIds = try await membershipService.find(userId: userId).map { $0.id }
        var result: [Attendance] = []
        for id in membershipsIds {
            let attendances = try await attendanceService.find(membershipId: id)
            result.append(contentsOf: attendances)
        }
        return result
    }

    public func cancelAttendance(attendanceId: UUID, userId: UUID) async throws {
        guard let attendance = try await attendanceService.find(id: attendanceId) else {
            throw AttendanceError.attendanceNotFound
        }
        let membershipIds = try await membershipService.find(userId: userId).map { $0.id }
        guard membershipIds.contains(attendance.membershipId) else {
            throw AttendanceError.invalidMembershipId
        }
        guard let training = try await trainingService.find(id: attendance.trainingId),
              training.date > .now else {
            throw AttendanceError.invalidUpdate
        }
        try await attendanceService.delete(id: attendanceId)
    }

    public func signUp(trainingId: UUID, membershipId: UUID, userId: UUID) async throws -> Attendance? {
        let membership = try await membershipService.find(id: membershipId)
        guard let membership,
              membership.userId == userId else {
            throw AttendanceError.invalidMembershipId
        }
        guard let training = try await trainingService.find(id: trainingId),
              training.date > .now else {
            throw AttendanceError.invalidTrainingId
        }
        let createDTO = AttendanceCreateDTO(
            membershipId: membershipId,
            trainingId: trainingId,
            status: AttendanceStatus.waiting
        )
        return try await attendanceService.create(createDTO)
    }
}
