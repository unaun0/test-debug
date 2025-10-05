//
//  MembershipTypeDTO.swift
//  Backend
//
//  Created by Цховребова Яна on 22.03.2025.
//

import Vapor

public struct MembershipTypeDTO: Content {
    public let id: UUID
    public let name: String
    public let price: Double
    public let sessions: Int
    public let days: Int

    public init(
        id: UUID,
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

// MARK: - Init from Model

extension MembershipTypeDTO {
    public init(from membershipType: MembershipType) {
        self.id = membershipType.id
        self.name = membershipType.name
        self.price = membershipType.price
        self.sessions = membershipType.sessions
        self.days = membershipType.days
    }
}

// MARK: - Equatable

extension MembershipTypeDTO: Equatable {
    public static func == (
        lhs: MembershipTypeDTO,
        rhs: MembershipTypeDTO
    ) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.price == rhs.price
            && lhs.sessions == rhs.sessions
            && lhs.days == rhs.days
    }
}

// MARK: - Update

public struct MembershipTypeUpdateDTO: Content {
    public let name: String?
    public let price: Double?
    public let sessions: Int?
    public let days: Int?
}

// MARK: - Create

public struct MembershipTypeCreateDTO: Content {
    public let name: String
    public let price: Double
    public let sessions: Int
    public let days: Int
}
