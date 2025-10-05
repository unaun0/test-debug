//
//  TrainerCreateValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 13.04.2025.
//

import Vapor
import Domain

public struct TrainerCreateValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        do {
            let json = try request.content.decode([String: String].self)
            guard
                let userId = json["userId"],
                !userId.isEmpty,
                UUID(uuidString: userId) != nil
            else { throw TrainerError.invalidUserId }
            guard
                let desc = json["description"],
                TrainerValidator.validate(description: desc)
            else { throw TrainerError.invalidDescription }
            
            return try await next.respond(to: request)
        } catch { throw error }
    }
}
