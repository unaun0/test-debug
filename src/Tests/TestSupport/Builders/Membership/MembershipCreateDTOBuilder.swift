//
//  MembershipCreateDTOBuilder.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 07.09.2025.
//

import Vapor
@testable import Domain


public final class MembershipCreateDTOBuilder {
    private var userId: UUID = UUID()
    private var membershipTypeId: UUID = UUID()

    public init() {}

    public func withUserId(_ userId: UUID) -> Self { self.userId = userId; return self }
    public func withMembershipTypeId(_ membershipTypeId: UUID) -> Self { self.membershipTypeId = membershipTypeId; return self }

    public func build() -> MembershipCreateDTO {
        MembershipCreateDTO(
            userId: userId,
            membershipTypeId: membershipTypeId
        )
    }
}
