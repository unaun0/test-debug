//
//  IMembershipRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Vapor

/// @mockable
public protocol IMembershipRepository: Sendable {
    func create(_ membership: Membership) async throws
    func update(_ membership: Membership) async throws
    func delete(id: UUID) async throws
    func find(id: UUID) async throws -> Membership?
    func find(userId: UUID) async throws -> [Membership]
    func find(membershipTypeId: UUID) async throws -> [Membership]
    func findAll() async throws -> [Membership]
}
