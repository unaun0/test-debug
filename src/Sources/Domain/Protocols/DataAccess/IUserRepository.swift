//
//  IUserRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 10.03.2025.
//

import Vapor

/// @mockable
public protocol IUserRepository: Sendable {
    func create(_ user: User) async throws
    func update(_ user: User) async throws
    func delete(id: UUID) async throws
    func find(email: String) async throws -> User?
    func find(id: UUID) async throws -> User?
    func find(phoneNumber: String) async throws -> User?
    func findAll() async throws -> [User]
    func find(role: String) async throws -> [User]
}
