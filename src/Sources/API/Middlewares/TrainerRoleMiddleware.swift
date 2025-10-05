//
//  TrainerRoleMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 20.03.2025.
//

import Vapor
import Domain

public final class TrainerRoleMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        guard let user = request.auth.get(User.self) else {
            throw AuthError.missingToken
        }
        guard user.role == UserRoleName.trainer else {
            throw UserError.permissionDenied
        }
        return try await next.respond(to: request)
    }
}
