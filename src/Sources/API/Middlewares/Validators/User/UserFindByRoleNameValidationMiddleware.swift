//
//  UserFindByRoleNameValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 11.04.2025.
//

import Vapor
import Domain

public struct UserRoleNameValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        guard
            let role = request.parameters.get("role"),
            UserValidator.validate(roleName: role)
        else { throw UserError.invalidRole }

        return try await next.respond(to: request)
    }
}
