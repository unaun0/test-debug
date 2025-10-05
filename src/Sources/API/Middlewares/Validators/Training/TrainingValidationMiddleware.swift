//
//  TrainingValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 13.04.2025.
//

import Vapor
import Domain

public struct TrainingValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        do {
            let json = try request.content.decode([String: String].self)
            if let trainerId = json["trainerId"] {
                guard
                    !trainerId.isEmpty,
                    UUID(uuidString: trainerId) != nil
                else { throw TrainingError.invalidTrainer }
            }
            if let roomId = json["roomId"] {
                guard
                    !roomId.isEmpty,
                    UUID(uuidString: roomId) != nil
                else { throw TrainingError.invalidRoom }
            }
            if let dateString = json["date"] {
                guard
                    let date = dateString.toDate(format: "yyyy-MM-dd HH:mm:ss"),
                    TrainingValidator.validate(date: date)
                else { throw TrainingError.invalidDate }
            }
            return try await next.respond(to: request)
        } catch { throw error }
    }
}
