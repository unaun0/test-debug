//
//  MembershipEntity.swift
//  Backend
//
//  Created by Цховребова Яна on 18.04.2025.
//

import Fluent
import Vapor
import Domain

public final class MembershipDBDTO: Model {
    public static let schema = "Membership"

    @ID(custom: "id")
    public var id: UUID?

    @Field(key: "user_id")
    public var userId: UUID

    @Field(key: "membership_type_id")
    public var membershipTypeId: UUID

    @Field(key: "start_date")
    public var startDate: Date?

    @Field(key: "end_date")
    public var endDate: Date?

    @Field(key: "available_sessions")
    public var availableSessions: Int

    public init() {}
}

// MARK: - Convenience Initializator

extension MembershipDBDTO {
    public convenience init(
        id: UUID? = nil,
        userId: UUID,
        membershipTypeId: UUID,
        startDate: Date? = nil,
        endDate: Date? = nil,
        availableSessions: Int
    ) {
        self.init()

        self.id = id
        self.userId = userId
        self.membershipTypeId = membershipTypeId
        self.startDate = startDate
        self.endDate = endDate
        self.availableSessions = availableSessions
    }
}

// MARK: - Sendable

extension MembershipDBDTO: @unchecked Sendable {}

// MARK: - Content

extension MembershipDBDTO: Content {}

// MARK: - From / To Model

extension MembershipDBDTO {
    public convenience init(
        from membership: Membership
    ) {
        self.init()

        self.id = membership.id
        self.userId = membership.userId
        self.membershipTypeId = membership.membershipTypeId
        self.startDate = membership.startDate
        self.endDate = membership.endDate
        self.availableSessions = membership.availableSessions
    }

    public func toMembership() -> Membership? {
        guard let id = self.id else { return nil }

        return Membership(
            id: id,
            userId: userId,
            membershipTypeId: membershipTypeId,
            startDate: startDate,
            endDate: endDate,
            availableSessions: availableSessions
        )
    }
}
