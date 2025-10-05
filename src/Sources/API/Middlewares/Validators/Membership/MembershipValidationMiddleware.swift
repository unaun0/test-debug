//
//  MembershipValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 18.04.2025.
//

import Vapor
import Domain

public struct MembershipValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        do {
            if let membershipTypeId = try? request.content.get(String.self, at: "membershipTypeId") {
                guard UUID(uuidString: membershipTypeId) != nil
                else { throw MembershipError.invalidMembershipTypeId }
            }
            if let userId = try? request.content.get(String.self, at: "userId") {
                guard
                    UUID(uuidString: userId) != nil
                else { throw MembershipError.invalidUserId }
            }
            let startDate = try? request.content.get(String.self, at: "startDate").toDate(
                format: ValidationRegex.DateFormat.format
            )
            let endDate = try? request.content.get(String.self, at: "endDate").toDate(
                format: ValidationRegex.DateFormat.format
            )
            guard MembershipValidator.validate(
                startDate: startDate,
                endDate: endDate
            ) else {
                throw MembershipError.invalidDate
            }
            if let sessions  = try? request.content.get(Int.self, at: "availableSessions") {
                guard
                    MembershipValidator.validate(sessions: sessions)
                else { throw MembershipError.invalidAvailableSessions }
            }
            
            return try await next.respond(to: request)
        } catch { throw error }
    }
}
