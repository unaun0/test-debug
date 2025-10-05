//
//  TrainerSelfController.swift
//  Backend
//
//  Created by Цховребова Яна on 10.05.2025.
//

import Vapor
import VaporToOpenAPI
import Domain

public final class TrainerSelfController: RouteCollection {
    private let service: ITrainerSelfService
    private let jwtMiddleware: JWTMiddleware
    private let trainerMiddleware: AdminOrTrainerRoleMiddleware

    public init(
        service: ITrainerSelfService,
        jwtMiddleware: JWTMiddleware,
        trainerMiddleware: AdminOrTrainerRoleMiddleware
    ) {
        self.service = service
        self.jwtMiddleware = jwtMiddleware
        self.trainerMiddleware = trainerMiddleware
    }

    public func boot(routes: RoutesBuilder) throws {
        let routes = routes.grouped(
            "trainer"
        ).grouped(
            jwtMiddleware
        ).grouped(
            trainerMiddleware
        )
        routes.grouped(
            "me"
        ).get(
            use: getProfile
        ).openAPI(
            tags: .init(name: "Trainer - Profile"),
            summary: "Получить профиль тренера",
            description:
                "Возвращает профиль тренера. Требуются права тренера.",
            response: .type(TrainerDTO.self),
            auth: .bearer()
        )
    }
}

// MARK: - Routes Realization

extension TrainerSelfController {
    @Sendable
    func getProfile(req: Request) async throws -> Response {
        let trainer = try await service.getProfile(
            userId: req.auth.require(User.self).id
        )
        guard let trainer else {
            throw TrainerError.trainerNotFound
        }
        return try await TrainerDTO(
            from: trainer
        ).encodeResponse(status: .ok, for: req)
    }
}

extension TrainerSelfController: @unchecked Sendable {}
