//
//  MembershipTypeRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 13.04.2025.
//

import Fluent
import Vapor
import Domain

public final class MembershipTypeMongoDBRepository {
    private let db: Database

    public init(db: Database) {
        self.db = db
    }
}

// MARK: - IMembershipTypeRepository

extension MembershipTypeMongoDBRepository: IMembershipTypeRepository {
    public func create(_ membershipType: MembershipType) async throws {
        try await MembershipTypeMongoDBDTO(
            from: membershipType
        ).create(on: db)
    }

    public func update(_ membershipType: MembershipType) async throws {
        guard
            let existing = try await MembershipTypeMongoDBDTO.find(
                membershipType.id,
                on: db
            )
        else {
            throw MembershipTypeError.membershipTypeNotFound
        }

        existing.name = membershipType.name
        existing.price = membershipType.price
        existing.sessions = membershipType.sessions
        existing.days = membershipType.days

        try await existing.update(on: db)
    }

    public func find(id: UUID) async throws -> MembershipType? {
        try await MembershipTypeMongoDBDTO.find(
            id, on: db
        )?.toMembershipType()
    }

    public func find(name: String) async throws -> MembershipType? {
        try await MembershipTypeMongoDBDTO.query(
            on: db
        ).filter(
            \.$name == name
        ).first()?.toMembershipType()
    }

    public func findAll() async throws -> [MembershipType] {
        try await MembershipTypeMongoDBDTO.query(
            on: db
        ).all().compactMap { $0.toMembershipType() }
    }

    public func delete(id: UUID) async throws {
        guard
            let mt = try await MembershipTypeMongoDBDTO.find(
                id,
                on: db
            )
        else {
            throw MembershipTypeError.membershipTypeNotFound
        }

        try await mt.delete(on: db)
    }
}
