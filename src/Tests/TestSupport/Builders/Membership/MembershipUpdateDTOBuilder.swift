//
//  MembershipUpdateDTOBuilder.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 07.09.2025.
//


import Vapor
@testable import Domain


public final class MembershipUpdateDTOBuilder {
    private var userId: UUID? = UUID()
    private var membershipTypeId: UUID? = UUID()
    private var startDate: String? = "2025-09-07"
    private var endDate: String? = "2025-10-07"
    private var availableSessions: Int? = 10

    public init() {}

    public func withUserId(_ userId: UUID?) -> Self { self.userId = userId; return self }
    public func withMembershipTypeId(_ membershipTypeId: UUID?) -> Self { self.membershipTypeId = membershipTypeId; return self }
    public func withStartDate(_ date: String?) -> Self { self.startDate = date; return self }
    public func withEndDate(_ date: String?) -> Self { self.endDate = date; return self }
    public func withAvailableSessions(_ sessions: Int?) -> Self { self.availableSessions = sessions; return self }

    public func build() -> MembershipUpdateDTO {
        MembershipUpdateDTO(
            userId: userId,
            membershipTypeId: membershipTypeId,
            startDate: startDate,
            endDate: endDate,
            availableSessions: availableSessions
        )
    }
}
