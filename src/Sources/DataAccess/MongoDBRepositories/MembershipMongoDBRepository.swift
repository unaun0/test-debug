//
//  MembershipRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 18.04.2025.
//

import Fluent
import Vapor
import Domain

public final class MembershipMongoDBRepository {
    private let db: Database

    public init(db: Database) {
        self.db = db
    }
}

// MARK: - IMembershipRepository

extension MembershipMongoDBRepository: IMembershipRepository {
    public func create(_ membership: Membership) async throws {
        try await MembershipMongoDBDTO(
            from: membership
        ).create(on: db)
    }

    public func update(_ membership: Membership) async throws {
        guard
            let existing = try await MembershipMongoDBDTO.find(
                membership.id,
                on: db
            )
        else {
            throw MembershipError.membershipNotFound
        }
        existing.userId = membership.userId
        existing.membershipTypeId = membership.membershipTypeId
        existing.startDate = membership.startDate
        existing.endDate = membership.endDate
        existing.availableSessions = membership.availableSessions

        try await existing.update(on: db)
    }

    public func find(id: UUID) async throws -> Membership? {
        try await MembershipMongoDBDTO.find(id, on: db)?.toMembership()
    }

    public func find(userId: UUID) async throws -> [Membership] {
        try await MembershipMongoDBDTO.query(
            on: db
        ).filter(
            \.$userId == userId
        ).all().compactMap { $0.toMembership() }
    }

    public func find(membershipTypeId: UUID) async throws -> [Membership] {
        try await MembershipMongoDBDTO.query(
            on: db
        ).filter(
            \.$membershipTypeId == membershipTypeId
        ).all().compactMap { $0.toMembership() }
    }

    public func findAll() async throws -> [Membership] {
        try await MembershipMongoDBDTO.query(
            on: db
        ).all().compactMap { $0.toMembership() }
    }

    public func delete(id: UUID) async throws {
        guard
            let membership = try await MembershipMongoDBDTO.find(
                id,
                on: db
            )
        else {
            throw MembershipError.membershipNotFound
        }
        
        try await membership.delete(on: db)
    }
}
