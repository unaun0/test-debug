//
//  MembershipDTO.swift
//  Backend
//
//  Created by Цховребова Яна on 27.03.2025.
//

import Vapor

public struct MembershipDTO: Content {
    public let id: UUID
    public let userId: UUID
    public let membershipTypeId: UUID
    public let startDate: String?
    public let endDate: String?
    public let availableSessions: Int

    public init(
        id: UUID,
        userId: UUID,
        membershipTypeId: UUID,
        startDate: String?,
        endDate: String?,
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

// MARK: - Init from Model

extension MembershipDTO {
    public init(from membership: Membership) {
        self.id = membership.id
        self.userId = membership.userId
        self.membershipTypeId = membership.membershipTypeId
        self.startDate = membership.startDate?.toString(
            format: ValidationRegex.DateFormat.format
        )
        self.endDate = membership.endDate?.toString(
            format: ValidationRegex.DateFormat.format
        )
        self.availableSessions = membership.availableSessions
    }
}

// MARK: - Equatable

extension MembershipDTO: Equatable {
    public static func == (
        lhs: MembershipDTO,
        rhs: MembershipDTO
    ) -> Bool {
        return lhs.id == rhs.id
            && lhs.userId == rhs.userId
            && lhs.membershipTypeId == rhs.membershipTypeId
            && lhs.startDate == rhs.startDate
            && lhs.endDate == rhs.endDate
            && lhs.availableSessions == rhs.availableSessions
    }
}

// MARK: - Update

public struct MembershipUpdateDTO: Content {
    public let userId: UUID?
    public let membershipTypeId: UUID?
    public let startDate: String?
    public let endDate: String?
    public let availableSessions: Int?
}

// MARK: - Create

public struct MembershipCreateDTO: Content {
    public let userId: UUID
    public let membershipTypeId: UUID
}
