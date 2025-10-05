//
//  MembershipTypeService.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Vapor

public final class MembershipTypeService: IMembershipTypeService {
    private let repository: IMembershipTypeRepository

    public init(repository: IMembershipTypeRepository) {
        self.repository = repository
    }

    public func create(
        _ data: MembershipTypeCreateDTO
    ) async throws -> MembershipType? {
        if try await repository.find(
            name: data.name
        ) != nil {
            throw MembershipTypeError.nameAlreadyExists
        }
        let membershipType = MembershipType(
            id: UUID(),
            name: data.name,
            price: data.price,
            sessions: data.sessions,
            days: data.days
        )
        try await repository.create(membershipType)

        return membershipType
    }

    public func update(
        id: UUID,
        with data: MembershipTypeUpdateDTO
    ) async throws -> MembershipType? {
        guard
            let membershipType = try await repository.find(
                id: id
            )
        else { throw MembershipTypeError.membershipTypeNotFound }
        if let name = data.name {
            if try await repository.find(
                name: name
            ) != nil {
                throw MembershipTypeError.nameAlreadyExists
            }
            membershipType.name = name
        }
        if let price = data.price {
            membershipType.price = price
        }
        if let sessions = data.sessions {
            membershipType.sessions = sessions
        }
        if let days = data.days {
            membershipType.days = days
        }
        try await repository.update(
            membershipType
        )

        return membershipType
    }

    public func find(id: UUID) async throws -> MembershipType? {
        try await repository.find(id: id)
    }

    public func find(name: String) async throws -> MembershipType? {
        try await repository.find(name: name)
    }

    public func findAll() async throws -> [MembershipType] {
        try await repository.findAll()
    }

    public func delete(id: UUID) async throws {
        guard
            let _ = try await repository.find(id: id)
        else {
            throw MembershipTypeError.membershipTypeNotFound
        }
        try await repository.delete(id: id)
    }
}
