//
//  MembershipCreateValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 18.04.2025.
//

import Vapor
import Domain

public struct MembershipCreateValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        do {
            let json = try request.content.decode([String: String].self)
            guard
                let membershipTypeId = json["membershipTypeId"],
                UUID(uuidString: membershipTypeId) != nil
            else { throw MembershipError.invalidMembershipTypeId }
            guard
                let userId = json["userId"],
                UUID(uuidString: userId) != nil
            else { throw MembershipError.invalidUserId }
            return try await next.respond(to: request)
        } catch { throw error }
    }
}
