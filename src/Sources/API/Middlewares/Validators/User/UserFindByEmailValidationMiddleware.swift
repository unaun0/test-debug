//
//  UserFindByEmailValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 11.04.2025.
//

import Vapor
import Domain

public struct UserEmailValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        guard
            let email = request.parameters.get("email"),
                UserValidator.validate(email: email)
        else { throw UserError.invalidEmail }
        
        return try await next.respond(to: request)
    }
}
