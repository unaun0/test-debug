//
//  UserRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 10.03.2025.

import Fluent
import Vapor
import Domain

public final class UserRepository {
    private let db: Database
    
    public init(db: Database) {
        self.db = db
    }
}

// MARK: - IUserRepository

extension UserRepository: IUserRepository {
    public func create(_ user: User) async throws {
        try await UserDBDTO(from: user).create(on: db)
    }

    public func update(_ user: User) async throws {
        guard let existing = try await UserDBDTO.find(
            user.id, on: db
        ) else {
            throw UserRepositoryError.userNotFound
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

    public func find(email: String) async throws -> User? {
        try await UserDBDTO.query(
            on: db
        ).filter(
            \.$email == email
        ).first()?.toUser()
    }

    public func find(role: String) async throws -> [User] {
        try await UserDBDTO.query(
            on: db
        ).filter(
            \.$role == role
        ).all().compactMap { $0.toUser() }
    }
    
    public func find(phoneNumber: String) async throws -> User? {
        try await UserDBDTO.query(
            on: db
        ).filter(
            \.$phoneNumber == phoneNumber
        ).first()?.toUser()
    }

    public func find(id: UUID) async throws -> User? {
        try await UserDBDTO.find(
            id,
            on: db
        )?.toUser()
    }

    public func findAll() async throws -> [User] {
        try await UserDBDTO.query(
            on: db
        ).all().compactMap { $0.toUser() }
    }

    public func delete(id: UUID) async throws {
        guard let user = try await UserDBDTO.find(
            id,
            on: db
        ) else {
            throw UserRepositoryError.userNotFound
        }
        
        try await user.delete(on: db)
    }
}

public enum UserRepositoryError: Error, LocalizedError {
    case userNotFound

    public var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "Пользователь не найден."
        }
    }
}
