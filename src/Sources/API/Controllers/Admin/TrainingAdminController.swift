//
//  TrainingController.swift
//  Backend
//
//  Created by Цховребова Яна on 15.04.2025.
//

import Vapor
import VaporToOpenAPI
import Domain

public final class TrainingAdminController: RouteCollection {
    private let trainingService: ITrainingService
    private let jwtMiddleware: JWTMiddleware
    private let adminMiddleware: AdminRoleMiddleware
    private let createMiddleware: TrainingCreateValidationMiddleware
    private let updateMiddleware: TrainingValidationMiddleware
    private let uuidMiddleware: UUIDValidationMiddleware
    
    public init(
        trainingService: ITrainingService,
        adminRoleMiddleware: AdminRoleMiddleware,
        jwtMiddleware: JWTMiddleware,
        createValidationMiddleware: TrainingCreateValidationMiddleware,
        validationMiddleware: TrainingValidationMiddleware,
        uuidValidationMiddleware: UUIDValidationMiddleware
    ) {
        self.trainingService = trainingService
        self.adminMiddleware = adminRoleMiddleware
        self.jwtMiddleware = jwtMiddleware
        self.createMiddleware = createValidationMiddleware
        self.updateMiddleware = validationMiddleware
        self.uuidMiddleware = uuidValidationMiddleware
    }
    
    public func boot(routes: RoutesBuilder) throws {
        let trainingRoutes = routes.grouped(
            "admin", "trainings"
        ).grouped(
            jwtMiddleware
        ).grouped(
            adminMiddleware
        )
        trainingRoutes.get(
            "all",
            use: getAllTrainings
        ).openAPI(
            tags: .init(name: "Admin - Training"),
            summary: "Получить список тренировок для администратора",
            description:
                "Возвращает все тренировки, доступных текущему администратору.",
            response: .type([TrainingDTO].self),
            auth: .bearer()
        )
        trainingRoutes.grouped(
            uuidMiddleware
        ).get(
            ":id",
            use: getTrainingById
        ).openAPI(
            tags: .init(name: "Admin - Training"),
            summary: "Получить тренировку по ID для администратора",
            description:
                "Возвращает тренировку по ее UUID. Требует прав администратора.",
            response: .type(TrainingDTO.self),
            auth: .bearer()
        )
        trainingRoutes.grouped(
            uuidMiddleware
        ).get(
            "trainer",
            ":trainer-id",
            use: getTrainingByTrainerId
        ).openAPI(
            tags: .init(name: "Admin - Training"),
            summary: "Получить тренировки по ID тренера для администратора",
            description:
                "Возвращает тренировки по UUID тренера. Требует прав администратора.",
            response: .type([TrainingDTO].self),
            auth: .bearer()
        )
        trainingRoutes.grouped(
            uuidMiddleware
        ).get(
            "room",
            ":room-id",
            use: getTrainingByRoomId
        ).openAPI(
            tags: .init(name: "Admin - Training"),
            summary: "Получить тренировки по ID зала для администратора",
            description:
                "Возвращает тренировки по UUID зала. Требует прав администратора.",
            response: .type([TrainingDTO].self),
            auth: .bearer()
        )
        trainingRoutes.grouped(
            createMiddleware
        ).post(
            use: createTraining
        ).openAPI(
            tags: .init(name: "Admin - Training"),
            summary: "Создать новую тренировку для администратора",
            description:
                "Создает новую тренировку. Требует прав администратора.",
            body: .type(TrainingCreateDTO.self),
            response: .type(TrainingDTO.self),
            auth: .bearer()
        )
        trainingRoutes.grouped(
            uuidMiddleware
        ).grouped(
            updateMiddleware
        ).put(
            ":id",
            use: updateTrainingById
        ).openAPI(
            tags: .init(name: "Admin - Training"),
            summary: "Обновить тренировку для администратора",
            description:
                "Обновляет данные тренировки. Требует прав администратора.",
            body: .type(TrainingUpdateDTO.self),
            response: .type(TrainingDTO.self),
            auth: .bearer()
        )
        trainingRoutes.grouped(
            uuidMiddleware
        ).delete(
            ":id",
            use: deleteTrainingById
        ).openAPI(
            tags: .init(name: "Admin - Training"),
            summary: "Удалить тренировку по ID для администратора",
            description:
                "Удаляет тренировку по ее UUID. Требует прав администратора.",
            response: .type([TrainingDTO].self),
            auth: .bearer()
        )
    }
}

// MARK: - Routes Realization

extension TrainingAdminController {
    @Sendable
    func getAllTrainings(
        req: Request
    ) async throws -> Response {
        try await trainingService.findAll().map {
            TrainingDTO(from: $0)
        }.encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func createTraining(req: Request) async throws -> Response {
        guard let training = try await trainingService.create(
            try req.content.decode(
                TrainingCreateDTO.self
            )
        ) else {
            throw TrainingError.invalidCreation
        }
        return try await TrainingDTO(
            from: training
        ).encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func updateTrainingById(req: Request)
    async throws -> Response {
        guard let training = try await trainingService.update(
            id: try req.parameters.require(
                "id",
                as: UUID.self
            ),
            with: try req.content.decode(
                TrainingUpdateDTO.self
            )
        ) else {
            throw TrainingError.invalidUpdate
        }
        return try await TrainingDTO(
            from: training
        ).encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func deleteTrainingById(req: Request)
    async throws -> HTTPStatus {
        try await trainingService.delete(
            id: try req.parameters.require(
                "id",
                as: UUID.self
            )
        )
        return .noContent
    }

    @Sendable
    func getTrainingById(req: Request)
    async throws -> Response {
        guard
            let training = try await trainingService.find(
                id: try req.parameters.require(
                    "id",
                    as: UUID.self
                )
            )
        else { throw TrainingError.trainingNotFound }
        return try await TrainingDTO(
            from: training
        ).encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func getTrainingByTrainerId(req: Request)
    async throws -> Response {
        return try await trainingService.find(
            trainerId: try req.parameters.require(
                "trainer-id",
                as: UUID.self
            )
        ).map {
            TrainingDTO(from: $0)
        }.encodeResponse(status: .ok, for: req)
    }
    
    @Sendable
    func getTrainingByRoomId(req: Request)
    async throws -> Response {
        return try await trainingService.find(
            trainingRoomId: try req.parameters.require(
                "room-id",
                as: UUID.self
            )
        ).map {
            TrainingDTO(from: $0)
        }.encodeResponse(status: .ok, for: req)
    }
}

extension TrainingAdminController: @unchecked Sendable {}
