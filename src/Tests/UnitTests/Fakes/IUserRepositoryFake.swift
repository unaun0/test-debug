//
//  IUserRepositoryFake.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 07.09.2025.
//

import Foundation
import Domain

public actor IUserRepositoryFake {
    private var users: [User] = []
    
    public init() {}
    
    public func reset() {
        users.removeAll()
    }
}

// MARK: - IUserRepository

extension IUserRepositoryFake: IUserRepository {
    public func create(_ user: User) async throws {
        if users.contains(where: { $0.email == user.email }) {
            throw UserError.emailAlreadyExists
        }
        if users.contains(where: { $0.phoneNumber == user.phoneNumber }) {
            throw UserError.phoneNumberAlreadyExists
        }
        users.append(user)
    }

    public func update(_ user: User) async throws {
        guard let index = users.firstIndex(where: { $0.id == user.id }) else {
            throw UserError.userNotFound
        }
        users[index] = user
    }

    public func delete(id: UUID) async throws {
        guard let index = users.firstIndex(where: { $0.id == id }) else {
            throw UserError.userNotFound
        }
        users.remove(at: index)
    }

    public func find(email: String) async throws -> User? {
        users.first { $0.email == email }
    }

    public func find(phoneNumber: String) async throws -> User? {
        users.first { $0.phoneNumber == phoneNumber }
    }

    public func find(id: UUID) async throws -> User? {
        users.first { $0.id == id }
    }
    
    public func find(role: String) async throws -> [User] {
        users.filter { $0.role.rawValue == role }
    }

    public func findAll() async throws -> [User] {
        users
    }
}
