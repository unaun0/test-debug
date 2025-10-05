//
//  Attendance.swift
//  Backend
//
//  Created by Цховребова Яна on 18.04.2025.
//

import Fluent
import Vapor
import Domain

public final class AttendanceMongoDBDTO: Model {
    public static let schema = "Attendance"

    @ID(custom: "_id")
    public var id: UUID?

    @Field(key: "membership_id")
    public var membershipId: UUID

    @Field(key: "training_id")
    public var trainingId: UUID

    @Field(key: "status")
    public var status: String

    public init() {}
}

// MARK: - Convenience Initializator

extension AttendanceMongoDBDTO {
    public convenience init(
        id: UUID? = nil,
        membershipId: UUID,
        trainingId: UUID,
        status: String
    ) {
        self.init()
        
        self.id = id
        self.membershipId = membershipId
        self.trainingId = trainingId
        self.status = status
    }
}

// MARK: - Sendable

extension AttendanceMongoDBDTO: @unchecked Sendable {}

// MARK: - Content

extension AttendanceMongoDBDTO: Content {}

// MARK: - From / To Model

extension AttendanceMongoDBDTO {
    public convenience init(from attendance: Attendance) {
        self.init()
        
        self.id = attendance.id
        self.membershipId = attendance.membershipId
        self.trainingId = attendance.trainingId
        self.status = attendance.status.rawValue
    }

    public func toAttendance() -> Attendance? {
        guard
            let id = self.id,
            let status = AttendanceStatus(rawValue: self.status)
        else { return nil }

        return Attendance(
            id: id,
            membershipId: membershipId,
            trainingId: trainingId,
            status: status
        )
    }
}
