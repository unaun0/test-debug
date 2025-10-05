//
//  MembershipTypeUpdateDTOBuilder.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 07.09.2025.
//

import Vapor
@testable import Domain


public final class MembershipTypeUpdateDTOBuilder {
    private var name: String? = "Standard"
    private var price: Double? = 100.0
    private var sessions: Int? = 10
    private var days: Int? = 30

    public init() {}

    public func withName(_ name: String?) -> Self { self.name = name; return self }
    public func withPrice(_ price: Double?) -> Self { self.price = price; return self }
    public func withSessions(_ sessions: Int?) -> Self { self.sessions = sessions; return self }
    public func withDays(_ days: Int?) -> Self { self.days = days; return self }

    public func build() -> MembershipTypeUpdateDTO {
        return MembershipTypeUpdateDTO(
            name: name,
            price: price,
            sessions: sessions,
            days: days
        )
    }
}
