//
//  MembershipTypeEntity.swift
//  Backend
//
//  Created by Цховребова Яна on 12.03.2025.
//

import Fluent
import Vapor
import Domain

public final class MembershipTypeMongoDBDTO: Model {
    public static let schema = "MembershipType"

    @ID(custom: "id")
    public var id: UUID?

    @Field(key: "name")
    public var name: String

    @Field(key: "price")
    public var price: Double

    @Field(key: "sessions")
    public var sessions: Int

    @Field(key: "days")
    public var days: Int

    public init() {}
}

// MARK: - Convenience Initializator

extension MembershipTypeMongoDBDTO {
    public convenience init(
        id: UUID? = nil,
        name: String,
        price: Double,
        sessions: Int,
        days: Int
    ) {
        self.init()
        
        self.id = id
        self.name = name
        self.price = price
        self.sessions = sessions
        self.days = days
    }
}

// MARK: - Sendable

extension MembershipTypeMongoDBDTO: @unchecked Sendable {}

// MARK: - Content

extension MembershipTypeMongoDBDTO: Content {}

// MARK: - From / To Model

extension MembershipTypeMongoDBDTO {
    public convenience init(from membershipType: MembershipType) {
        self.init()
        
        self.id = membershipType.id
        self.name = membershipType.name
        self.price = membershipType.price
        self.sessions = membershipType.sessions
        self.days = membershipType.days
    }

    public func toMembershipType() -> MembershipType? {
        guard let id = self.id else { return nil }

        return MembershipType(
            id: id,
            name: name,
            price: price,
            sessions: sessions,
            days: days
        )
    }
}
