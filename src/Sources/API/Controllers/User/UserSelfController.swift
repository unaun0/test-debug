//
//  UserController.swift
//  Backend
//
//  Created by Цховребова Яна on 20.03.2025.
//

import Domain
import Vapor
import VaporToOpenAPI

public final class UserSelfController: RouteCollection {
    private let service: IUserSelfService
    private let jwtMiddleware: JWTMiddleware
    private let validationMiddleware: UserValidationMiddleware

    public init(
        service: IUserSelfService,
        jwtMiddleware: JWTMiddleware,
        validationMiddleware: UserValidationMiddleware
    ) {
        self.service = service
        self.jwtMiddleware = jwtMiddleware
        self.validationMiddleware = validationMiddleware
    }

    public func boot(routes: RoutesBuilder) throws {
        let userRoutes = routes.grouped("user").grouped(jwtMiddleware)
        userRoutes.get(
            "me", use: getProfile
        ).openAPI(
            tags: .init(name: "User - Profile"),
            summary: "Получить профиль пользователя",
            description:
                "Возвращает информацию о текущем пользователе по его ID.",
            response: .type(UserDTO.self),
            auth: .bearer()
        )
        userRoutes.grouped(validationMiddleware).put(
            "me", use: updateProfile
        ).openAPI(
            tags: .init(name: "User - Profile"),
            summary: "Обновить профиль пользователя",
            description: "Позволяет пользователю обновить свою информацию.",
            body: .type(UserSelfUpdateDTO.self),
            response: .type(UserDTO.self),
            auth: .bearer()
        )
        userRoutes.delete(
            "me", use: deleteProfile
        ).openAPI(
            tags: .init(name: "User - Profile"),
            summary: "Удалить профиль пользователя",
            description: "Удаляет профиль текущего пользователя.",
            response: .type(HTTPStatus.self),
            auth: .bearer()
        )
        userRoutes.get(
            "role", use: getRole
        ).openAPI(
            tags: .init(name: "User - Profile"),
            summary: "Получить роль пользователя",
            response: .type(String.self),
            auth: .bearer()
        )
    }
}

// MARK: - Routes Realization

extension UserSelfController {
    @Sendable
    func getProfile(req: Request) async throws -> Response {
        let user = try await service.getMyProfile(
            id: req.auth.require(User.self).id
        )
        guard let user else {
            throw UserError.userNotFound
        }
        return try await UserDTO(from: user)
            .encodeResponse(status: .ok, for: req)
    }

    func getRole(req: Request) async throws -> Response {
        let user = try await service.getMyProfile(
            id: req.auth.require(User.self).id
        )
        guard let user else {
            throw UserError.userNotFound
        }
        return try await user.role.encodeResponse(
            status: .ok,
            for: req
        )
    }

    @Sendable
    func updateProfile(req: Request) async throws -> Response {
        let dto = try req.content.decode(UserSelfUpdateDTO.self)

        // Печатаем полученные данные
        print("📦 Полученные данные:")
        dump(dto)

        let userId = try req.auth.require(User.self).id
        guard
            let updatedUser = try await service.updateMyProfile(
                id: userId, data: dto)
        else { throw UserError.updateFailed }

        return try await UserDTO(from: updatedUser)
            .encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func deleteProfile(req: Request) async throws -> HTTPStatus {
        try await service.deleteMyProfile(
            id: try req.auth.require(User.self).id
        )
        return .noContent
    }
}

extension UserSelfController: @unchecked Sendable {}
