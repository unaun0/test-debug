//
//  IAttendanceRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Vapor

/// @mockable
public protocol IAttendanceRepository: Sendable {
    func create(_ attendance: Attendance) async throws
    func update(_ attendance: Attendance) async throws
    func delete(id: UUID) async throws
    func find(id: UUID) async throws -> Attendance?
    func find(trainingId: UUID) async throws -> [Attendance]
    func find(membershipId: UUID) async throws -> [Attendance]
    func findAll() async throws -> [Attendance]
}
