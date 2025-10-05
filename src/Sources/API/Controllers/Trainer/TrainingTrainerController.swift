//
//  Training.swift
//  Backend
//
//  Created by Цховребова Яна on 10.05.2025.
//

import Vapor
import VaporToOpenAPI
import Domain

public final class TrainingTrainerController: RouteCollection {
    private let trainingService: ITrainingTrainerService
    private let jwtMiddleware: JWTMiddleware
    private let trainerMiddleware: AdminOrTrainerRoleMiddleware
    private let createMiddleware: TrainingCreateValidationMiddleware
    private let updateMiddleware: TrainingValidationMiddleware
    private let uuidMiddleware: UUIDValidationMiddleware
    
    public init(
        trainingService: ITrainingTrainerService,
        jwtMiddleware: JWTMiddleware,
        trainerMiddleware: AdminOrTrainerRoleMiddleware,
        createMiddleware: TrainingCreateValidationMiddleware,
        updateMiddleware: TrainingValidationMiddleware,
        uuidMiddleware: UUIDValidationMiddleware
    ) {
        self.trainingService = trainingService
        self.jwtMiddleware = jwtMiddleware
        self.trainerMiddleware = trainerMiddleware
        self.createMiddleware = createMiddleware
        self.updateMiddleware = updateMiddleware
        self.uuidMiddleware = uuidMiddleware
    }
    
    public func boot(routes: RoutesBuilder) throws {
        let trainingRoutes = routes.grouped(
            "trainer", "trainings"
        ).grouped(
            jwtMiddleware
        ).grouped(
            trainerMiddleware
        )
        trainingRoutes.get(
            "all",
            use: getAllTrainings
        ).openAPI(
            tags: .init(name: "Trainer - Training"),
            summary: "Получить список всех тренировок для тренера",
            description:
                "Возвращает все тренировки тренера. Требует прав тренера.",
            response: .type([TrainingInfoDTO].self),
            auth: .bearer()
        )
        trainingRoutes.get(
            "current",
            use: getAllCurrentTrainings
        ).openAPI(
            tags: .init(name: "Trainer - Training"),
            summary: "Получить список всех доступных тренировок для тренера",
            description:
                "Возвращает все доступные тренировки тренера. Требует прав тренера.",
            response: .type([TrainingInfoDTO].self),
            auth: .bearer()
        )
    }
}

// MARK: - Routes Realization

extension TrainingTrainerController {
    @Sendable
    func getAllTrainings(
        req: Request
    ) async throws -> Response {
        try await trainingService.findAllTrainings(
            userId: req.auth.require(User.self).id
        ).encodeResponse(status: .ok, for: req)
    }
    
    @Sendable
    func getAllCurrentTrainings(
        req: Request
    ) async throws -> Response {
        try await trainingService.findAvailableTrainings(
            userId: req.auth.require(User.self).id
        ).encodeResponse(status: .ok, for: req)
    }
}

extension TrainingTrainerController: @unchecked Sendable {}
