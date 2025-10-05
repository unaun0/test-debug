//
//  TrainerValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 13.04.2025.
//

import Vapor
import Domain

public struct TrainerValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        do {
            let json = try request.content.decode([String: String].self)
            if let userId = json["userId"],
               userId.isEmpty,
               UUID(uuidString: userId) == nil {
                throw TrainerError.invalidUserId
            }
            if let desc = json["description"],
               !TrainerValidator.validate(description: desc) {
                throw TrainerError.invalidDescription
            }

            return try await next.respond(to: request)
        } catch { throw error }
    }
}
