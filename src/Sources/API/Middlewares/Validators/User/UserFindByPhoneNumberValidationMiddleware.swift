//
//  UserFindByPhoneNumberValidationMiddleware.swift.swift
//  Backend
//
//  Created by Цховребова Яна on 11.04.2025.
//

import Vapor
import Domain

public struct UserPhoneNumberValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        guard let phoneNumber = request.parameters.get("phone-number"),
            UserValidator.validate(phoneNumber: phoneNumber)
        else { throw UserError.invalidPhoneNumber }
        
        return try await next.respond(to: request)
    }
}
