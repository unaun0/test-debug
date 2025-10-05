//
//  MembershipUserController.swift
//  Backend
//
//  Created by Цховребова Яна on 11.05.2025.
//

import Vapor
import VaporToOpenAPI
import Domain

public final class MembershipUserController: RouteCollection {
    private let service: IMembershipService
    private let jwtMiddleware: JWTMiddleware

    public init(
        service: IMembershipService,
        jwtMiddleware: JWTMiddleware
    ) {
        self.service = service
        self.jwtMiddleware = jwtMiddleware
    }

    public func boot(routes: RoutesBuilder) throws {
        let routes = routes
            .grouped("user", "memberships")
            .grouped(jwtMiddleware)

        routes.get(use: getByUserId).openAPI(
            tags: .init(name: "User - Membership"),
            summary: "Получить абонементы текущего пользователя.",
            description: "Возвращает абонементы текущего пользователя.",
            response: .type([MembershipDTO].self),
            auth: .bearer()
        )
    }
}

// MARK: - Handlers

extension MembershipUserController {
    @Sendable
    func getByUserId(req: Request) async throws -> Response {
        try await service.find(
            userId: req.auth.require(User.self).id
        ).map {
            MembershipDTO(from: $0)
        }.encodeResponse(status: .ok, for: req)
    }
}

extension MembershipUserController: @unchecked Sendable {}
