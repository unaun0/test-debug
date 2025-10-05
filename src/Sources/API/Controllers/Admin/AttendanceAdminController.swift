//
//  AttendanceAdminController.swift
//  Backend
//
//  Created by Цховребова Яна on 12.05.2025.
//

import Vapor
import VaporToOpenAPI
import Domain

public final class AttendanceAdminController: RouteCollection {
    private let service: IAttendanceService
    private let jwtMiddleware: JWTMiddleware
    private let adminMiddleware: AdminRoleMiddleware
    private let uuidMiddleware: UUIDValidationMiddleware
    private let createMiddleware: AttendanceCreateValidationMiddleware
    private let updateMiddleware: AttendanceValidationMiddleware

    public init(
        service: IAttendanceService,
        jwtMiddleware: JWTMiddleware,
        adminMiddleware: AdminRoleMiddleware,
        uuidMiddleware: UUIDValidationMiddleware,
        createMiddleware: AttendanceCreateValidationMiddleware,
        updateMiddleware: AttendanceValidationMiddleware
    ) {
        self.service = service
        self.jwtMiddleware = jwtMiddleware
        self.adminMiddleware = adminMiddleware
        self.uuidMiddleware = uuidMiddleware
        self.createMiddleware = createMiddleware
        self.updateMiddleware = updateMiddleware
    }

    public func boot(routes: RoutesBuilder) throws {
        let routes = routes.grouped(
            "admin",
            "attendances"
        ).grouped(jwtMiddleware, adminMiddleware)

        routes.get("all", use: getAll).openAPI(
            tags: .init(name: "Admin - Attendance"),
            summary: "Получить все посещения для администратора",
            description:
                "Возвращает список всех посещений. Требует прав администратора.",
            response: .type([AttendanceDTO].self),
            auth: .bearer()
        )

        routes.grouped(uuidMiddleware).get(":id", use: getById).openAPI(
            tags: .init(name: "Admin - Attendance"),
            summary: "Получить посещение по ID для администратора",
            description:
                "Возвращает посещение по UUID. Требует прав администратора.",
            response: .type(AttendanceDTO.self),
            auth: .bearer()
        )

        routes.grouped(uuidMiddleware).delete(":id", use: deleteById).openAPI(
            tags: .init(name: "Admin - Attendance"),
            summary: "Удалить посещение по ID для администратора",
            description:
                "Удаляет посещение по UUID. Требует прав администратора.",
            response: .type(HTTPStatus.self),
            auth: .bearer()
        )

        routes.grouped(uuidMiddleware).get(
            "training", ":training-id", use: getByTrainingId
        ).openAPI(
            tags: .init(name: "Admin - Attendance"),
            summary: "Получить посещения по тренировке для администратора",
            description:
                "Возвращает список посещений по UUID тренировки. Требует прав администратора.",
            response: .type([AttendanceDTO].self),
            auth: .bearer()
        )

        routes.grouped(uuidMiddleware).get(
            "membership", ":membership-id", use: getByMembershipId
        ).openAPI(
            tags: .init(name: "Admin - Attendance"),
            summary: "Получить посещения по абонементу для администратора",
            description:
                "Возвращает список посещений по UUID абонемента. Требует прав администратора.",
            response: .type([AttendanceDTO].self),
            auth: .bearer()
        )

        routes.grouped(createMiddleware).post(use: create).openAPI(
            tags: .init(name: "Admin - Attendance"),
            summary: "Создать посещение для администратора",
            body: .type(AttendanceCreateDTO.self),
            response: .type(AttendanceDTO.self),
            auth: .bearer()
        )

        routes.grouped(uuidMiddleware, updateMiddleware).put(":id", use: update)
            .openAPI(
                tags: .init(name: "Admin - Attendance"),
                summary: "Обновить посещение для администратора",
                body: .type(AttendanceUpdateDTO.self),
                response: .type(AttendanceDTO.self),
                auth: .bearer()
            )
    }
}

// MARK: - Handlers

extension AttendanceAdminController {
    @Sendable
    func getAll(req: Request) async throws -> Response {
        try await service.findAll().map(AttendanceDTO.init(from:))
            .encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func getById(req: Request) async throws -> Response {
        guard
            let result = try await service.find(
                id: try req.parameters.require("id", as: UUID.self)
            )
        else {
            throw AttendanceError.attendanceNotFound
        }
        return try await AttendanceDTO(from: result)
            .encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func deleteById(req: Request) async throws -> HTTPStatus {
        try await service.delete(
            id: try req.parameters.require("id", as: UUID.self)
        )
        return .noContent
    }

    @Sendable
    func getByTrainingId(req: Request) async throws -> Response {
        try await service.find(
            trainingId: try req.parameters.require("training-id", as: UUID.self)
        ).map(AttendanceDTO.init(from:))
            .encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func getByMembershipId(req: Request) async throws -> Response {
        try await service.find(
            membershipId: try req.parameters.require(
                "membership-id", as: UUID.self)
        ).map(AttendanceDTO.init(from:))
            .encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func create(req: Request) async throws -> Response {
        guard
            let result = try await service.create(
                try req.content.decode(AttendanceCreateDTO.self)
            )
        else {
            throw AttendanceError.invalidCreation
        }
        return try await AttendanceDTO(from: result)
            .encodeResponse(status: .created, for: req)
    }

    @Sendable
    func update(req: Request) async throws -> Response {
        guard
            let result = try await service.update(
                id: try req.parameters.require("id", as: UUID.self),
                with: try req.content.decode(AttendanceUpdateDTO.self)
            )
        else {
            throw AttendanceError.invalidUpdate
        }
        return try await AttendanceDTO(from: result)
            .encodeResponse(status: .ok, for: req)
    }
}

extension AttendanceAdminController: @unchecked Sendable {}
