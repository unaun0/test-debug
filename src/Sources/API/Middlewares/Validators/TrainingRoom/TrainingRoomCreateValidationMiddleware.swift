//
//  TrainingRoomCreateValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 13.04.2025.
//

import Vapor
import Domain

public struct TrainingRoomCreateValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        do {
            let name = try request.content.get(String.self, at: "name")
            guard TrainingRoomValidator.validate(name: name) else {
                throw TrainingRoomError.invalidName
            }
            let capacity = try request.content.get(Int.self, at: "capacity")
            guard TrainingRoomValidator.validate(capacity: capacity) else {
                throw TrainingRoomError.invalidCapacity
            }
            return try await next.respond(to: request)
        } catch {
            throw error
        }
    }
}
