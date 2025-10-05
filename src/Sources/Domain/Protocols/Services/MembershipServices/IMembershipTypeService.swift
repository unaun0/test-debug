//
//  IMembershipTypeService.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Vapor

/// @mockable
public protocol IMembershipTypeService: Sendable {
    func create(_ data: MembershipTypeCreateDTO) async throws -> MembershipType?
    func update(id: UUID, with data: MembershipTypeUpdateDTO) async throws -> MembershipType?
    func find(id: UUID) async throws -> MembershipType?
    func find(name: String) async throws -> MembershipType?
    func findAll() async throws -> [MembershipType]
    func delete(id: UUID) async throws
}
