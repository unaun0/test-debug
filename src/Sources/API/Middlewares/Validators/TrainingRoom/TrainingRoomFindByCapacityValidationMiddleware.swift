//
//  TrainingRoomFindByCapacityValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 13.04.2025.
//

import Vapor
import Domain

public struct TrainingRoomFindByCapacityValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        guard
            let capacityString = request.parameters.get("capacity"),
            let capacity = Int(capacityString),
            TrainingRoomValidator.validate(capacity: capacity)
        else { throw TrainingRoomError.invalidCapacity }

        return try await next.respond(to: request)
    }
}
