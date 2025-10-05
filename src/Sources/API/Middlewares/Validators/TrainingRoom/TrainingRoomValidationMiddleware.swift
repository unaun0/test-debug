//
//  TrainingRoomValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 13.04.2025.
//

import Vapor
import Domain

public struct TrainingRoomValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        do {
            if let name = try? request.content.get(String.self, at: "name"),
                !name.isEmpty, !TrainingRoomValidator.validate(name: name)
            {
                throw TrainingRoomError.invalidName
            }
            if let capacity = try? request.content.get(
                Int.self, at: "capacity"
            ), !TrainingRoomValidator.validate(capacity: capacity)
            {
                throw TrainingRoomError.invalidCapacity
            }
            return try await next.respond(to: request)
        } catch {
            throw error
        }
    }
}
