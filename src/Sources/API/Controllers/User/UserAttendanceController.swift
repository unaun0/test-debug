//
//  AttendanceUserController.swift
//  Backend
//
//  Created by Цховребова Яна on 12.05.2025.
//

import Vapor
import VaporToOpenAPI
import Domain

public final class AttendanceUserController: RouteCollection {
    private let attendanceService: IAttendanceUserService
    private let jwtMiddleware: JWTMiddleware
    private let uuidMiddleware: UUIDValidationMiddleware
    private let dataMiddleware: AttendanceValidationMiddleware
    
    public init(
        attendanceService: IAttendanceUserService,
        jwtMiddleware: JWTMiddleware,
        uuidMiddleware: UUIDValidationMiddleware,
        dataMiddleware: AttendanceValidationMiddleware
    ) {
        self.attendanceService = attendanceService
        self.jwtMiddleware = jwtMiddleware
        self.uuidMiddleware = uuidMiddleware
        self.dataMiddleware = dataMiddleware
        
    }
    
    public func boot(routes: RoutesBuilder) throws {
        let attendanceRoutes = routes
            .grouped("user", "attendances")
            .grouped(jwtMiddleware)
        
        attendanceRoutes.get(
            use: getMyAttendances
        ).openAPI(
            tags: .init(name: "User - Attendance"),
            summary: "Получить все посещения пользователя",
            description: "Возвращает список всех записей на тренировки по абонементам пользователя.",
            response: .type([AttendanceDTO].self),
            auth: .bearer()
        )
        
        attendanceRoutes.grouped(uuidMiddleware, dataMiddleware).post(
            "sign-up",
            use: signUp
        ).openAPI(
            tags: .init(name: "User - Attendance"),
            summary: "Записаться на тренировку",
            description: "Пользователь записывается на тренировку с активным абонементом.",
            body: .type(AttendanceSignUpDTO.self),
            response: .type(AttendanceDTO.self),
            auth: .bearer()
        )
        
        attendanceRoutes.grouped(uuidMiddleware).delete(
            ":attendance-id",
            use: cancelAttendance
        ).openAPI(
            tags: .init(name: "User - Attendance"),
            summary: "Отменить запись на тренировку",
            description: "Отменяет запись на тренировку, если она ещё не состоялась.",
            response: .type(HTTPStatus.self),
            auth: .bearer()
        )
    }
}

extension AttendanceUserController {
    @Sendable
    func getMyAttendances(req: Request) async throws -> Response {
        let userId = try req.auth.require(User.self).id
        let attendances = try await attendanceService.getMyAttendances(userId: userId)
        return try await attendances.map(AttendanceDTO.init(from:)).encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func signUp(req: Request) async throws -> Response {
        let userId = try req.auth.require(User.self).id
        let dto = try req.content.decode(AttendanceSignUpDTO.self)
        let attendance = try await attendanceService.signUp(
            trainingId: dto.trainingId,
            membershipId: dto.membershipId,
            userId: userId
        )
        guard let attendance else {
            throw Abort(
                .internalServerError, reason: "Не удалось создать запись на тренировку."
            )
        }
        return try await AttendanceDTO(from: attendance).encodeResponse(status: .ok, for: req)
    }

    @Sendable
    func cancelAttendance(req: Request) async throws -> HTTPStatus {
        let userId = try req.auth.require(User.self).id
        let attendanceId = try req.parameters.require("attendance-id", as: UUID.self)
        try await attendanceService.cancelAttendance(attendanceId: attendanceId, userId: userId)
        return .noContent
    }
}

extension AttendanceUserController: @unchecked Sendable {}
