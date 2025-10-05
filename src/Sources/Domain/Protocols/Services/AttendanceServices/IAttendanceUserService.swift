//
//  IAttendanceUserService.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 02.09.2025.
//

import Vapor

public protocol IAttendanceUserService: Sendable {
    func getMyAttendances(userId: UUID) async throws -> [Attendance]
    func cancelAttendance(attendanceId: UUID, userId: UUID) async throws
    func signUp(trainingId: UUID, membershipId: UUID, userId: UUID) async throws -> Attendance?
}
