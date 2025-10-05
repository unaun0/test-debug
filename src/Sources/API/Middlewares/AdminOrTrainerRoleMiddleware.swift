//
//  AdminOrTrainerRoleMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 20.03.2025.
//

import Vapor
import Domain

public struct AdminOrTrainerRoleMiddleware: AsyncMiddleware {
    private let adminMiddleware: AdminRoleMiddleware
    private let trainerMiddleware: TrainerRoleMiddleware

    public init(
        adminMiddleware: AdminRoleMiddleware,
        trainerMiddleware: TrainerRoleMiddleware
    ) {
        self.adminMiddleware = adminMiddleware
        self.trainerMiddleware = trainerMiddleware
    }

    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        do {
            return try await adminMiddleware.respond(
                to: request,
                chainingTo: next
            )
        } catch {
            if (error as? UserError) == .permissionDenied {
                do {
                    return try await trainerMiddleware.respond(
                        to: request,
                        chainingTo: next
                    )
                } catch {
                    throw error
                }
            } else {
                throw error
            }
        }
    }
}
