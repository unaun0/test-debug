//
//  IMembershipService.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Vapor

public protocol IMembershipService: Sendable {
    func create(_ data: MembershipCreateDTO) async throws -> Membership?
    func update(id: UUID, with data: MembershipUpdateDTO) async throws -> Membership?
    func find(id: UUID) async throws -> Membership?
    func find(userId: UUID) async throws -> [Membership]
    func find(membershipTypeId: UUID) async throws -> [Membership]
    func findAll() async throws -> [Membership]
    func delete(id: UUID) async throws
}
