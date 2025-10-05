//
//  MembershipService.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Vapor

public final class MembershipService: IMembershipService {
    private let membershipRepository: IMembershipRepository
    private let membershipTypeService: IMembershipTypeService

    public init(
        membershipRepository: IMembershipRepository,
        membershipTypeService: IMembershipTypeService
    ) {
        self.membershipRepository = membershipRepository
        self.membershipTypeService = membershipTypeService
    }
    
    public func create(_ data: MembershipCreateDTO) async throws -> Membership? {
        guard let mt = try await membershipTypeService.find(
            id: data.membershipTypeId
        )
        else {
            throw MembershipError.invalidMembershipTypeId
        }
        let membership = Membership(
            id: UUID(),
            userId: data.userId,
            membershipTypeId: data.membershipTypeId,
            startDate: nil,
            endDate: nil,
            availableSessions: mt.sessions
        )
        try await membershipRepository.create(membership)
        return membership
    }
    
    public func update(
        id: UUID,
        with data: MembershipUpdateDTO
    ) async throws -> Membership? {
        guard let membership = try await membershipRepository.find(id: id)
        else { throw MembershipError.membershipNotFound }
        if let user = data.userId {
            membership.userId = user
        }
        if let membershipType = data.membershipTypeId {
            membership.membershipTypeId = membershipType
        }
        if let startDate = data.startDate {
            membership.startDate = startDate.toDate(
                format: ValidationRegex.DateFormat.format
            )
        }
        if let endDate = data.endDate {
            membership.endDate = endDate.toDate(
                format: ValidationRegex.DateFormat.format
            )
        }
        if let availableSessions = data.availableSessions {
            membership.availableSessions = availableSessions
        }
        try await membershipRepository.update(membership)
        
        return membership
    }

    public func find(id: UUID) async throws -> Membership? {
        try await membershipRepository.find(id: id)
    }

    public func find(userId: UUID) async throws -> [Membership] {
        try await membershipRepository.find(userId: userId)
    }

    public func find(membershipTypeId: UUID) async throws -> [Membership] {
        try await membershipRepository.find(
            membershipTypeId: membershipTypeId
        )
    }

    public func findAll() async throws -> [Membership] {
        try await membershipRepository.findAll()
    }

    public func delete(id: UUID) async throws {
        guard
            let _ = try await membershipRepository.find(id: id)
        else {
            throw MembershipError.membershipNotFound
        }
        try await membershipRepository.delete(id: id)
    }
}
