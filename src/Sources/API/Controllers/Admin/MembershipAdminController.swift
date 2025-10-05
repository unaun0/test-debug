//
//  MembershipAdminController.swift
//  Backend
//
//  Created by Цховребова Яна on 11.05.2025.
//

import Vapor
import VaporToOpenAPI
import Domain

public final class MembershipAdminController: RouteCollection {
    private let service: IMembershipService
    private let jwtMiddleware: JWTMiddleware
    private let adminMiddleware: AdminRoleMiddleware
    private let uuidMiddleware: UUIDValidationMiddleware
    private let createMiddleware: MembershipCreateValidationMiddleware
    private let updateMiddleware: MembershipValidationMiddleware

    public init(
        service: IMembershipService,
        jwtMiddleware: JWTMiddleware,
        adminMiddleware: AdminRoleMiddleware,
        uuidMiddleware: UUIDValidationMiddleware,
        createMiddleware: MembershipCreateValidationMiddleware,
        updateMiddleware: MembershipValidationMiddleware
    ) {
        self.service = service
        self.jwtMiddleware = jwtMiddleware
        self.adminMiddleware = adminMiddleware
        self.uuidMiddleware = uuidMiddleware
        self.createMiddleware = createMiddleware
        self.updateMiddleware = updateMiddleware
    }

    public func boot(routes: RoutesBuilder) throws {
        let routes = routes
            .grouped("admin", "memberships")
            .grouped(jwtMiddleware, adminMiddleware)

        routes.get("all", use: getAll).openAPI(
            tags: .init(name: "Admin - Membership"),
            summary: "Получить все абонементы для администратора",
            description: "Возвращает список всех абонементов. Требует прав администратора.",
            response: .type([MembershipDTO].self),
            auth: .bearer()
        )

        routes.grouped(uuidMiddleware).get(":id", use: getById).openAPI(
            tags: .init(name: "Admin - Membership"),
            summary: "Получить абонемент по ID для администратора",
            description: "Возвращает абонемент по UUID. Требует прав администратора.",
            response: .type(MembershipDTO.self),
            auth: .bearer()
        )

        routes.grouped(uuidMiddleware).delete(":id", use: deleteById).openAPI(
            tags: .init(name: "Admin - Membership"),
            summary: "Удалить абонемент по ID для администратора",
            description: "Удаляет абонемент по UUID. Требует прав администратора.",
            response: .type(HTTPStatus.self),
            auth: .bearer()
        )

        routes.grouped(uuidMiddleware).get("user", ":user-id", use: getByUserId).openAPI(
            tags: .init(name: "Admin - Membership"),
            summary: "Получить абонементы по ID пользователя для администратора",
            description: "Возвращает абонементы по UUID пользователя. Требует прав администратора.",
            response: .type([MembershipDTO].self),
            auth: .bearer()
        )

        routes.grouped(uuidMiddleware).get("type", ":membership-type-id", use: getByMembershipTypeId).openAPI(
            tags: .init(name: "Admin - Membership"),
            summary: "Получить абонементы по типу для администратора",
            description: "Возвращает абонементы по UUID типа абонемента. Требует прав администратора.",
            response: .type([MembershipDTO].self),
            auth: .bearer()
        )

        routes.grouped(createMiddleware).post(use: create).openAPI(
            tags: .init(name: "Admin - Membership"),
            summary: "Создать абонемент для администратора",
            body: .type(MembershipCreateDTO.self),
            response: .type(MembershipDTO.self),
            auth: .bearer()
        )

        routes.grouped(uuidMiddleware, updateMiddleware).put(":id", use: update).openAPI(
            tags: .init(name: "Admin - Membership"),
            summary: "Обновить абонемент для администратора",
            body: .type(MembershipUpdateDTO.self),
            response: .type(MembershipDTO.self),
            auth: .bearer()
        )
    }
}

// MARK: - Handlers

extension MembershipAdminController {
    @Sendable
    func getAll(req: Request) async throws -> Response {
        try await service.findAll().map { MembershipDTO(from: $0) }
            .encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func getById(req: Request) async throws -> Response {
        guard let result = try await service.find(
            id: try req.parameters.require(
                "id",
                as: UUID.self
            )
        )
        else { throw MembershipError.membershipNotFound }
        return try await MembershipDTO(
            from: result
        ).encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func deleteById(req: Request) async throws -> HTTPStatus {
        try await service.delete(
            id: try req.parameters.require(
                "id",
                as: UUID.self
            )
        )
        return .noContent
    }

    @Sendable
    func getByUserId(req: Request) async throws -> Response {
        try await service.find(
            userId: try req.parameters.require(
                "user-id",
                as: UUID.self
            )
        ).map {
            MembershipDTO(from: $0)
        }.encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func getByMembershipTypeId(req: Request) async throws -> Response {
        try await service.find(
            membershipTypeId: try req.parameters.require(
                "membership-type-id",
                as: UUID.self
            )
        ).map {
            MembershipDTO(from: $0)
        }.encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func create(req: Request) async throws -> Response {
        guard let result = try await service.create(
            try req.content.decode(
                MembershipCreateDTO.self
            )
        )
        else { throw MembershipError.invalidCreation }
        return try await MembershipDTO(
            from: result
        ).encodeResponse(status: .created, for: req)
    }

    @Sendable
    func update(req: Request) async throws -> Response {
        guard let result = try await service.update(
            id: try req.parameters.require("id", as: UUID.self),
            with: try req.content.decode(MembershipUpdateDTO.self)
        ) else { throw MembershipError.invalidUpdate }
        return try await MembershipDTO(
            from: result
        ).encodeResponse(status: .ok, for: req)
    }
}

extension MembershipAdminController: @unchecked Sendable {}
