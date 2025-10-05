//
//  AttendanceDTO.swift
//  Backend
//
//  Created by Цховребова Яна on 27.03.2025.
//

import Vapor

public struct AttendanceDTO: Content {
    public let id: UUID
    public let membershipId: UUID
    public let trainingId: UUID
    public let status: AttendanceStatus

    public init(
        id: UUID,
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

// MARK: - Init from Model

extension AttendanceDTO {
    public init(from attendance: Attendance) {
        self.id = attendance.id
        self.membershipId = attendance.membershipId
        self.trainingId = attendance.trainingId
        self.status = attendance.status
    }
}

// MARK: - Equatable

extension AttendanceDTO: Equatable {
    public static func == (
        lhs: AttendanceDTO,
        rhs: AttendanceDTO
    ) -> Bool {
        return lhs.id == rhs.id
            && lhs.membershipId == rhs.membershipId
            && lhs.trainingId == rhs.trainingId
            && lhs.status == rhs.status
    }
}

// MARK: - Update

public struct AttendanceUpdateDTO: Content {
    public let membershipId: UUID?
    public let trainingId: UUID?
    public let status: AttendanceStatus?
}

// MARK: - Create

public struct AttendanceCreateDTO: Content {
    public let membershipId: UUID
    public let trainingId: UUID
    public let status: AttendanceStatus
}

// MARK: - Attendance Status

public struct AttendanceUpdateStatusDTO: Content {
    public let status: AttendanceStatus
}

// MARK: - Attendance Sign Up

public struct AttendanceSignUpDTO: Content {
    public let trainingId: UUID
    public let membershipId: UUID
}
