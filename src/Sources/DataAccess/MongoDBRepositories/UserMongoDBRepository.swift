//
//  UserMongoDBRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 29.05.2025.
//

import Vapor
import Fluent
import Domain

public final class UserMongoDBRepository: IUserRepository {
    private let db: Database

    public init(db: Database) {
        self.db = db
    }

    public func create(_ user: User) async throws {
        let dto = UserMongoDBDTO(from: user)
        try await dto.create(on: db)
    }

    public func update(_ user: User) async throws {
        guard let existing = try await UserMongoDBDTO.find(user.id, on: db) else {
            throw Abort(.notFound, reason: "User not found for id \(user.id)")
        }
        existing.email = user.email
        existing.phoneNumber = user.phoneNumber
        existing.password = user.password
        existing.firstName = user.firstName
        existing.lastName = user.lastName
        existing.birthDate = user.birthDate
        existing.gender = user.gender.rawValue
        existing.role = user.role.rawValue

        try await existing.update(on: db)
    }

    public func delete(id: UUID) async throws {
        guard let existing = try await UserMongoDBDTO.find(id, on: db) else {
            throw Abort(.notFound, reason: "User not found for id \(id)")
        }
        try await existing.delete(on: db)
    }

    public func find(email: String) async throws -> User? {
        guard let dto = try await UserMongoDBDTO.query(on: db)
            .filter(\.$email == email)
            .first() else {
                return nil
        }
        return dto.toUser()
    }

    public func find(id: UUID) async throws -> User? {
        guard let dto = try await UserMongoDBDTO.find(id, on: db) else {
            return nil
        }
        return dto.toUser()
    }

    public func find(phoneNumber: String) async throws -> User? {
        guard let dto = try await UserMongoDBDTO.query(on: db)
            .filter(\.$phoneNumber == phoneNumber)
            .first() else {
                return nil
        }
        return dto.toUser()
    }

    public func findAll() async throws -> [User] {
        let dtos = try await UserMongoDBDTO.query(on: db).all()
        return dtos.compactMap { $0.toUser() }
    }

    public func find(role: String) async throws -> [User] {
        let dtos = try await UserMongoDBDTO.query(on: db)
            .filter(\.$role == role)
            .all()
        return dtos.compactMap { $0.toUser() }
    }
}
