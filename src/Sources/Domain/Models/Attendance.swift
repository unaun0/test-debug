//
//  Attendance.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Vapor

// MARK: - AttendanceStatus

public enum AttendanceStatus: String {
    case attended = "посетил"
    case waiting = "ожидает"
    case absent = "отсутствовал"
}

// MARK: - AttendanceStatus CaseIterable

extension AttendanceStatus: CaseIterable {}

// MARK: - AttendanceStatus Content

extension AttendanceStatus: Content {}

// MARK: - Attendance Model

public final class Attendance: BaseModel {
    public var id: UUID
    public var membershipId: UUID
    public var trainingId: UUID
    public var status: AttendanceStatus

    public init(
        id: UUID = UUID(),
        membershipId: UUID,
        trainingId: UUID,
        status: AttendanceStatus
    ) {
        self.id = id
        self.membershipId = membershipId
        self.trainingId = trainingId
        self.status = status
    }
}

// MARK: - Attendance Equatable

extension Attendance: Equatable {
    public static func == (lhs: Attendance, rhs: Attendance) -> Bool {
        return lhs.id == rhs.id
            && lhs.membershipId == rhs.membershipId
            && lhs.trainingId == rhs.trainingId
            && lhs.status == rhs.status
    }
}

// MARK: - Attendance Sendable

extension Attendance: @unchecked Sendable {}
