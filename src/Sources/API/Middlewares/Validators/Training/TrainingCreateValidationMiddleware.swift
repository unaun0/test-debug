//
//  TrainingCreateValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 13.04.2025.
//

import Vapor
import Domain

public struct TrainingCreateValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        do {
            let json = try request.content.decode([String: String].self)
            guard
                let trainerId = json["trainerId"],
                !trainerId.isEmpty,
                UUID(uuidString: trainerId) != nil
            else { throw TrainingError.invalidTrainer }
            guard
                let roomId = json["roomId"],
                !roomId.isEmpty,
                UUID(uuidString: roomId) != nil
            else { throw TrainingError.invalidRoom }
            guard
                let date = json["date"]?.toDate(format: "yyyy-MM-dd HH:mm:ss"),
                TrainingValidator.validate(date: date)
            else { throw TrainingError.invalidDate }

            return try await next.respond(to: request)
        } catch { throw error }
    }
}
