//
//  Membership.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Vapor

// MARK: - Membership Model

public final class Membership: BaseModel {
    public var id: UUID
    public var userId: UUID
    public var membershipTypeId: UUID
    public var startDate: Date?
    public var endDate: Date?
    public var availableSessions: Int

    public init(
        id: UUID = UUID(),
        userId: UUID,
        membershipTypeId: UUID,
        startDate: Date? = nil,
        endDate: Date? = nil,
        availableSessions: Int
    ) {
        self.id = id
        self.userId = userId
        self.membershipTypeId = membershipTypeId
        self.startDate = startDate
        self.endDate = endDate
        self.availableSessions = availableSessions
    }
}

// MARK: - Membership Equatable

extension Membership: Equatable {
    public static func == (lhs: Membership, rhs: Membership) -> Bool {
        return lhs.id == rhs.id
            && lhs.userId == rhs.userId
            && lhs.membershipTypeId == rhs.membershipTypeId
            && Calendar.current.isDate(
                lhs.startDate ?? Date(),
                inSameDayAs: rhs.startDate ?? Date()
            )
            && Calendar.current.isDate(
                lhs.endDate ?? Date(),
                inSameDayAs: rhs.endDate ?? Date()
            )
            && lhs.availableSessions == rhs.availableSessions
    }
}

// MARK: - Membership Sendable

extension Membership: @unchecked Sendable {}
