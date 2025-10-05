//
//  MembershipType.swift
//  Backend
//
//  Created by Цховребова Яна on 12.03.2025.
//

import Vapor

// MARK: - MembershipType Model

public final class MembershipType: BaseModel {
    public var id: UUID
    public var name: String
    public var price: Double
    public var sessions: Int
    public var days: Int

    public init(
        id: UUID = UUID(),
        name: String,
        price: Double,
        sessions: Int,
        days: Int
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.sessions = sessions
        self.days = days
    }
}

// MARK: - MembershipType Equatable

extension MembershipType: Equatable {
    public static func == (lhs: MembershipType, rhs: MembershipType) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.price == rhs.price
            && lhs.sessions == rhs.sessions
            && lhs.days == rhs.days
    }
}

// MARK: - MembershipType Sendable

extension MembershipType: @unchecked Sendable {}
