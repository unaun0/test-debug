//
//  Training.swift
//  Backend
//
//  Created by Цховребова Яна on 10.05.2025.
//

import Vapor
import VaporToOpenAPI
import Domain

public final class TrainingUserController: RouteCollection {
    private let trainingService: ITrainingUserService
    private let jwtMiddleware: JWTMiddleware
    
    public init(
        trainingService: ITrainingUserService,
        jwtMiddleware: JWTMiddleware
    ) {
        self.trainingService = trainingService
        self.jwtMiddleware = jwtMiddleware
    }
    
    public func boot(routes: RoutesBuilder) throws {
        let trainingRoutes = routes.grouped(
            "user", "trainings"
        ).grouped(
            jwtMiddleware
        )
        trainingRoutes.get(
            "all",
            use: getAllTrainings
        ).openAPI(
            tags: .init(name: "User - Training"),
            summary: "Получить список доступных тренировок",
            description:
                "Возвращает все доступных тренировки.",
            response: .type([TrainingInfoDTO].self),
            auth: .bearer()
        )
    }
}

// MARK: - Routes Realization

extension TrainingUserController {
    @Sendable
    func getAllTrainings(
        req: Request
    ) async throws -> Response {
        try await trainingService
            .findAvailableTrainings()
            .encodeResponse(status: .ok, for: req)
    }
}

extension TrainingUserController: @unchecked Sendable {}
