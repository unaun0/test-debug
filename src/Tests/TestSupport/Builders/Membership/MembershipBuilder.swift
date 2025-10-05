//
//  MembershipBuilder.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 07.09.2025.
//

import Vapor
@testable import Domain

// MARK: - Membership Builder

public final class MembershipBuilder {
    private var id: UUID = UUID()
    private var userId: UUID = UUID()
    private var membershipTypeId: UUID = UUID()
    private var startDate: Date? = Date()
    private var endDate: Date? = Calendar.current.date(byAdding: .month, value: 1, to: Date())
    private var availableSessions: Int = 10

    public init() {}

    public func withId(_ id: UUID) -> Self { self.id = id; return self }
    public func withUserId(_ userId: UUID) -> Self { self.userId = userId; return self }
    public func withMembershipTypeId(_ membershipTypeId: UUID) -> Self { self.membershipTypeId = membershipTypeId; return self }
    public func withStartDate(_ date: Date?) -> Self { self.startDate = date; return self }
    public func withEndDate(_ date: Date?) -> Self { self.endDate = date; return self }
    public func withAvailableSessions(_ sessions: Int) -> Self { self.availableSessions = sessions; return self }

    public func build() -> Membership {
        Membership(
            id: id,
            userId: userId,
            membershipTypeId: membershipTypeId,
            startDate: startDate,
            endDate: endDate,
            availableSessions: availableSessions
        )
    }
}
