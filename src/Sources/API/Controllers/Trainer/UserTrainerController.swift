//
//  UserTrainerController.swift
//  Backend
//
//  Created by Цховребова Яна on 05.05.2025.
//

import Vapor
import VaporToOpenAPI
import Domain

public final class UserTrainerController: RouteCollection {
    private let service: IUserTrainerService
    private let jwtMiddleware: JWTMiddleware
    private let trainerMiddleware: AdminOrTrainerRoleMiddleware
    private let uuidMiddleware: UUIDValidationMiddleware
    private let emailMiddleware: UserEmailValidationMiddleware
    private let phoneMiddleware: UserPhoneNumberValidationMiddleware

    public init(
        service: IUserTrainerService,
        jwtMiddleware: JWTMiddleware,
        trainerMiddleware: AdminOrTrainerRoleMiddleware,
        uuidMiddleware: UUIDValidationMiddleware,
        emailMiddleware: UserEmailValidationMiddleware,
        phoneMiddleware: UserPhoneNumberValidationMiddleware
    ) {
        self.service = service
        self.jwtMiddleware = jwtMiddleware
        self.trainerMiddleware = trainerMiddleware
        self.uuidMiddleware = uuidMiddleware
        self.emailMiddleware = emailMiddleware
        self.phoneMiddleware = phoneMiddleware
    }

    public func boot(routes: RoutesBuilder) throws {
        let routes = routes.grouped(
            "trainer"
        ).grouped(
            "users"
        ).grouped(
            jwtMiddleware
        ).grouped(
            trainerMiddleware
        )
        routes.grouped(
            uuidMiddleware
        ).get(
            ":id", use: getClientById
        ).openAPI(
            tags: .init(name: "Trainer - User"),
            summary: "Получить клиента по ID для тренера",
            description:
                "Возвращает профиль клиента по его UUID. Требует прав тренера.",
            response: .type(UserDTO.self),
            auth: .bearer()
        )
    }
}

// MARK: - Routes Realization

extension UserTrainerController {
    @Sendable
    func getClientById(req: Request) async throws -> Response {
        guard
            let user = try await service.findClient(
                byID: try req.parameters.require("id", as: UUID.self)
            )
        else { throw UserError.userNotFound }
        return try await UserDTO(from: user).encodeResponse(for: req)
    }
}

extension UserTrainerController: @unchecked Sendable {}
