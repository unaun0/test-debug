//
//  MembershipTypeController.swift
//  Backend
//
//  Created by Цховребова Яна on 22.03.2025.
//

import Vapor
import VaporToOpenAPI
import Domain

public final class MembershipTypeAdminController: RouteCollection {
    private let service: IMembershipTypeService
    private let jwtMiddleware: JWTMiddleware
    private let adminMiddleware: AdminRoleMiddleware
    private let updateMiddleware: MembershipTypeValidationMiddleware
    private let createMiddleware: MembershipTypeCreateValidationMiddleware
    private let nameMiddleware: MembershipTypeFindByNameValidationMiddleware
    private let uuidMiddleware: UUIDValidationMiddleware
    
    public init(
        service: IMembershipTypeService,
        adminRoleMiddleware: AdminRoleMiddleware,
        jwtMiddleware: JWTMiddleware,
        membershipTypeValidationMiddleware: MembershipTypeValidationMiddleware,
        membershipTypeCreateValidationMiddleware: MembershipTypeCreateValidationMiddleware,
        membershipTypeFindByNameValidationMiddleware: MembershipTypeFindByNameValidationMiddleware,
        uuidValidationMiddleware: UUIDValidationMiddleware
    ) {
        self.service = service
        self.adminMiddleware = adminRoleMiddleware
        self.jwtMiddleware = jwtMiddleware
        self.updateMiddleware = membershipTypeValidationMiddleware
        self.createMiddleware = membershipTypeCreateValidationMiddleware
        self.nameMiddleware = membershipTypeFindByNameValidationMiddleware
        self.uuidMiddleware = uuidValidationMiddleware
    }
    
    public func boot(routes: RoutesBuilder) throws {
        let membershipTypeRoutes = routes.grouped(
            "admin", "membership-types"
        ).grouped(
            jwtMiddleware
        ).grouped(
            adminMiddleware
        )
        membershipTypeRoutes.get(
            "all",
            use: getAllMembershipTypes
        ).openAPI(
            tags: .init(name: "Admin - MembershipType"),
            summary: "Получить все типы абонементов для администратора",
            description: "Возвращает список всех типов абонемента. Требуются права администратора.",
            response: .type(MembershipTypeDTO.self),
            auth: .bearer()
        )
        membershipTypeRoutes.grouped(
            uuidMiddleware
        ).get(
            ":id",
            use: getMembershipTypeById
        ).openAPI(
            tags: .init(name: "Admin - MembershipType"),
            summary: "Получить тип абонемента по ID для администратора",
            description: "Возвращает тип абонемента по его UUID. Требуются права администратора.",
            response: .type(MembershipTypeDTO.self),
            auth: .bearer()
        )
        membershipTypeRoutes.grouped(
            nameMiddleware
        ).get(
            "name",
            ":name",
            use: getMembershipTypeByName
        ).openAPI(
            tags: .init(name: "Admin - MembershipType"),
            summary: "Получить тип абонемента по имени для администратора",
            description: "Возвращает тип абонемента по его имени. Требуются права администратора.",
            response: .type(MembershipTypeDTO.self),
            auth: .bearer()
        )
        membershipTypeRoutes.grouped(
            createMiddleware
        ).post(
            use: createMembershipType
        ).openAPI(
            tags: .init(name: "Admin - MembershipType"),
            summary: "Создать тип абонемента для администратора",
            description: "Создает тип абонемента. Требуются права администратора.",
            body: .type(MembershipTypeCreateDTO.self),
            response: .type(MembershipTypeDTO.self),
            auth: .bearer()
        )
        membershipTypeRoutes.grouped(
            uuidMiddleware
        ).grouped(
            updateMiddleware
        ).put(
            ":id",
            use: updateMembershipTypeById
        ).openAPI(
            tags: .init(name: "Admin - MembershipType"),
            summary: "Обновить тип абонемента для администратора",
            description: "Обновляет тип абонемента по UUID. Требуются права администратора.",
            body: .type(MembershipTypeUpdateDTO.self),
            response: .type(MembershipTypeDTO.self),
            auth: .bearer()
        )
        membershipTypeRoutes.grouped(
            uuidMiddleware
        ).delete(
            ":id",
            use: deleteMembershipTypeById
        ).openAPI(
            tags: .init(name: "Admin - MembershipType"),
            summary: "Удалить тип абонемента для администратора",
            description: "Удаляет тип абонемента по UUID. Требуются права администратора.",
            response: .type(MembershipTypeDTO.self),
            auth: .bearer()
        )
    }
}

extension MembershipTypeAdminController {
    @Sendable
    func getAllMembershipTypes(
        req: Request
    ) async throws -> Response {
        try await service.findAll().map {
            MembershipTypeDTO(from: $0)
        }.encodeResponse(status: .ok, for: req)
    }
    
    @Sendable
    func createMembershipType(req: Request) async throws -> Response {
        guard let mt = try await service.create(
            try req.content.decode(MembershipTypeCreateDTO.self)
        ) else {
            throw MembershipTypeError.invalidCreation
        }
        return try await MembershipTypeDTO(
            from: mt
        ).encodeResponse(status: .ok, for: req)
    }
    
    @Sendable
    func updateMembershipTypeById(req: Request) async throws -> Response {
        guard let mt = try await service.update(
            id: try req.parameters.require("id", as: UUID.self),
            with: try req.content.decode(MembershipTypeUpdateDTO.self)
        ) else {
            throw MembershipTypeError.invalidUpdate
        }
        return try await MembershipTypeDTO(
            from: mt
        ).encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func deleteMembershipTypeById(req: Request) async throws -> HTTPStatus {
        try await service.delete(
            id: try req.parameters.require(
                "id",
                as: UUID.self
            )
        )
        return .noContent
    }
    
    @Sendable
    func getMembershipTypeById(req: Request) async throws -> Response {
        guard
            let membershipType = try await service.find(
                id: try req.parameters.require("id", as: UUID.self)
            )
        else { throw MembershipTypeError.membershipTypeNotFound }
        return try await MembershipTypeDTO(
            from: membershipType
        ).encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func getMembershipTypeByName(req: Request) async throws -> Response {
        guard
            let membershipType = try await service.find(
                name: try req.parameters.require(
                    "name",
                    as: String.self
                )
            )
        else { throw MembershipTypeError.membershipTypeNotFound }
        return try await MembershipTypeDTO(
            from: membershipType
        ).encodeResponse(status: .ok, for: req)
    }
}

extension MembershipTypeAdminController: @unchecked Sendable {}
