//
//  JWTMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 20.03.2025.
//

import Vapor
import Domain

public struct JWTMiddleware: AsyncMiddleware {
    private let userService: IUserService

    public init(userService: IUserService) {
        self.userService = userService
    }

    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        guard
            let token = request.headers.bearerAuthorization?.token
        else {
            throw AuthError.missingToken
        }
        do {
            let payload = try request.jwt.verify(
                token,
                as: AuthPayload.self
            )
            let user = try await userService.find(
                id: payload.id
            )
            guard let user else {
                throw AuthError.invalidToken
            }
            request.auth.login(user)
        } catch let error {
            throw error
        }
        return try await next.respond(to: request)
    }
}
