//
//  TrainerUserController.swift
//  Backend
//
//  Created by Цховребова Яна on 10.05.2025.
//

import Vapor
import VaporToOpenAPI
import Domain

public final class TrainerUserController: RouteCollection {
    private let service: ITrainerUserService
    private let jwtMiddleware: JWTMiddleware
    private let uuidMiddleware: UUIDValidationMiddleware
    
    public init(
        service: ITrainerUserService,
        jwtMiddleware: JWTMiddleware,
        uuidMiddleware: UUIDValidationMiddleware
    ) {
        self.service = service
        self.jwtMiddleware = jwtMiddleware
        self.uuidMiddleware = uuidMiddleware
    }
    
    public func boot(routes: RoutesBuilder) throws {
        let trainerRoutes = routes.grouped("user", "trainers")
            .grouped(jwtMiddleware)
        
        trainerRoutes.grouped(uuidMiddleware).get(
            ":id",
            use: getTrainerById
        ).openAPI(
            tags: .init(name: "User - Trainer"),
            summary: "Получить тренера по ID",
            description: "Возвращает данные тренера по его UUID.",
            response: .type(TrainerInfoDTO.self),
            auth: .bearer()
        )
    }
}

// MARK: - Routes Realization

extension TrainerUserController {
    @Sendable
    func getTrainerById(req: Request) async throws -> Response {
        let id = try req.parameters.require("id", as: UUID.self)
        let (trainer, user) = try await service.findTrainer(byID: id)
        guard let trainer, let user else {
            throw TrainerError.trainerNotFound
        }
        return try await TrainerInfoDTO(
            id: trainer.id,
            userId: user.id,
            description: trainer.description,
            firstName: user.firstName,
            lastName: user.lastName
        ).encodeResponse(for: req)
    }
}

extension TrainerUserController: @unchecked Sendable {}
