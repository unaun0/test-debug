//
//  IMembershipTypeRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Vapor

/// @mockable
public protocol IMembershipTypeRepository: Sendable {
    func create(_ membershipType: MembershipType) async throws
    func update(_ membershipType: MembershipType) async throws
    func delete(id: UUID) async throws
    func find(id: UUID) async throws -> MembershipType?
    func find(name: String) async throws -> MembershipType?
    func findAll() async throws -> [MembershipType]
}
