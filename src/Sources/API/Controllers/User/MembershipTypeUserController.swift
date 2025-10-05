//
//  MembershipTypeController.swift
//  Backend
//
//  Created by Цховребова Яна on 11.05.2025.
//

import Vapor
import VaporToOpenAPI
import Domain

public final class MembershipTypeUserController: RouteCollection {
    private let service: IMembershipTypeService
    private let jwtMiddleware: JWTMiddleware
    
    public init(
        service: IMembershipTypeService,
        jwtMiddleware: JWTMiddleware
    ) {
        self.service = service
        self.jwtMiddleware = jwtMiddleware
    }
    
    public func boot(routes: RoutesBuilder) throws {
        let membershipTypeRoutes = routes.grouped(
            "user", "membership-types"
        ).grouped(
            jwtMiddleware
        )
        membershipTypeRoutes.get(
            "all",
            use: getAllMembershipTypes
        ).openAPI(
            tags: .init(name: "User - MembershipType"),
            summary: "Получить все типы абонементов",
            description: "Возвращает список всех типов абонемента.",
            response: .type(MembershipTypeDTO.self),
            auth: .bearer()
        )
    }
}

extension MembershipTypeUserController {
    @Sendable
    func getAllMembershipTypes(
        req: Request
    ) async throws -> Response {
        try await service.findAll().map {
            MembershipTypeDTO(from: $0)
        }.encodeResponse(status: .ok, for: req)
    }
}

extension MembershipTypeUserController: @unchecked Sendable {}
