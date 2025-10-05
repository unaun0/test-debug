//
//  TrainingRoomFindByNameValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 13.04.2025.
//

import Vapor
import Domain

public struct TrainingRoomFindByNameValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        guard
            let name = request.parameters.get("name"),
            TrainingRoomValidator.validate(name: name)
        else { throw TrainingRoomError.invalidName }

        return try await next.respond(to: request)
    }
}
