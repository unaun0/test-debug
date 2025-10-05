//
//  LoginValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 29.03.2025.
//

import Vapor
import Domain

public struct LoginValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        do {
            let json = try request.content.decode(
                [String: String].self
            )
            guard let login = json["login"] else {
                throw AuthError.missingLogin
            }
            if UserValidator.validate(email: login) {
            } else if UserValidator.validate(phoneNumber: login) {
            } else {
                throw UserError.invalidEmailOrPhoneNumber
            }
            guard let password = json["password"] else {
                throw AuthError.missingPassword
            }
            if UserValidator.validate(
                password: password
            ) {
            } else {
                throw UserError.invalidPassword
            }

            return try await next.respond(to: request)
        } catch { throw error }
    }
}
