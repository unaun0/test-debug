//
//  TrainerAdminController.swift
//  Backend
//
//  Created by Цховребова Яна on 23.03.2025.
//

import Vapor
import VaporToOpenAPI
import Domain

public final class TrainerAdminController: RouteCollection {
    private let service: ITrainerService
    private let jwtMiddleware: JWTMiddleware
    private let adminMiddleware: AdminRoleMiddleware
    private let trainerMiddleware: TrainerValidationMiddleware
    private let trainerCreateMiddleware: TrainerCreateValidationMiddleware
    private let uuidMiddleware: UUIDValidationMiddleware
    
    public init(
        service: ITrainerService,
        jwtMiddleware: JWTMiddleware,
        adminMiddleware: AdminRoleMiddleware,
        trainerMiddleware: TrainerValidationMiddleware,
        trainerCreateMiddleware: TrainerCreateValidationMiddleware,
        uuidMiddleware: UUIDValidationMiddleware
        
    ) {
        self.service = service
        self.adminMiddleware = adminMiddleware
        self.jwtMiddleware = jwtMiddleware
        self.trainerMiddleware = trainerMiddleware
        self.trainerCreateMiddleware = trainerCreateMiddleware
        self.uuidMiddleware = uuidMiddleware
    }
    
    public func boot(routes: RoutesBuilder) throws {
        let trainerRoutes = routes.grouped(
            "admin"
        ).grouped(
            "trainers"
        ).grouped(
            jwtMiddleware
        ).grouped(
            adminMiddleware
        )
        trainerRoutes.get(
            "all",
            use: getAllTrainers
        ).openAPI(
            tags: .init(name: "Admin - Trainer"),
            summary: "Получить список всех тренеров для администратора",
            description:
                "Возвращает всех тренеров, доступных текущему администратору.",
            response: .type([TrainerDTO].self),
            auth: .bearer()
        )
        trainerRoutes.grouped(
            uuidMiddleware
        ).get(
            ":id",
            use: getTrainerById
        ).openAPI(
            tags: .init(name: "Admin - Trainer"),
            summary: "Получить тренера по ID для администратора",
            description:
                "Возвращает данные тренера по его UUID. Требует прав администратора.",
            response: .type(TrainerDTO.self),
            auth: .bearer()
        )
        trainerRoutes.grouped(
            uuidMiddleware
        ).get(
            "user",
            ":user-id",
            use: getTrainerByUserId
        ).openAPI(
            tags: .init(name: "Admin - Trainer"),
            summary: "Получить тренера по ID пользователя для администратора",
            description:
                "Возвращает данные тренера по UUID пользователя. Требует прав администратора.",
            response: .type(TrainerDTO.self),
            auth: .bearer()
        )
        trainerRoutes.grouped(
            trainerCreateMiddleware
        ).grouped(adminMiddleware).post(
            use: createTrainer
        ).openAPI(
            tags: .init(name: "Admin - Trainer"),
            summary: "Создать тренера для администратора",
            description:
                "Создает нового тренера. Требует прав администратора.",
            body: .type(TrainerCreateDTO.self),
            response: .type(TrainerDTO.self),
            auth: .bearer()
        )
        trainerRoutes.grouped(
            uuidMiddleware
        ).grouped(
            trainerMiddleware
        ).grouped(adminMiddleware).put(
            ":id",
            use: updateTrainerById
        ).openAPI(
            tags: .init(name: "Admin - Trainer"),
            summary: "Обновить данные тренера по ID для администратора",
            description:
                "Обновляет данные тренера по его UUID. Требует прав администратора.",
            body: .type(TrainerUpdateDTO.self),
            response: .type(TrainerDTO.self),
            auth: .bearer()
        )
        trainerRoutes.grouped(
            uuidMiddleware
        ).grouped(adminMiddleware).delete(
            ":id",
            use: deleteTrainerById
        ).openAPI(
            tags: .init(name: "Admin - Trainer"),
            summary: "Удалить тренера по ID для администратора",
            description:
                "Удаляет тренера по его UUID. Требует прав администратора.",
            response: .type(HTTPStatus.self),
            auth: .bearer()
        )
    }
}

// MARK: - Routes Realization

extension TrainerAdminController {
    @Sendable
    func getAllTrainers(
        req: Request
    ) async throws -> Response {
        try await service.findAll().map {
            TrainerDTO(from: $0)
        }.encodeResponse(for: req)
    }

    @Sendable
    func createTrainer(req: Request) async throws -> Response {
        guard let trainer = try await service.create(
            try req.content.decode(TrainerCreateDTO.self)
        ) else { throw TrainerError.invalidCreation }
        return try await TrainerDTO(
            from: trainer
        ).encodeResponse(for: req)
    }

    @Sendable
    func updateTrainerById(req: Request) async throws -> Response {
        guard let trainer = try await service.update(
            id: try req.parameters.require("id", as: UUID.self),
            with: try req.content.decode(TrainerUpdateDTO.self)
        ) else { throw TrainerError.invalidUpdate }
        return try await TrainerDTO(
            from: trainer
        ).encodeResponse(for: req)
    }

    @Sendable
    func deleteTrainerById(req: Request) async throws -> HTTPStatus {
        try await service.delete(
            id: try req.parameters.require("id", as: UUID.self)
        )
        return .noContent
    }

    @Sendable
    func getTrainerById(req: Request) async throws -> Response {
        guard let trainer = try await service.find(
            id: try req.parameters.require(
                "id",
                as: UUID.self
            )
        )
        else { throw TrainerError.trainerNotFound }
        return try await TrainerDTO(
            from: trainer
        ).encodeResponse(for: req)
    }

    @Sendable
    func getTrainerByUserId(req: Request) async throws -> Response {
        guard let trainer = try await service.find(
            userId: try req.parameters.require(
                "user-id",
                as: UUID.self
            )
        ) else { throw TrainerError.trainerNotFound }

        return try await TrainerDTO(
            from: trainer
        ).encodeResponse(for: req)
    }
}

extension TrainerAdminController: @unchecked Sendable {}

