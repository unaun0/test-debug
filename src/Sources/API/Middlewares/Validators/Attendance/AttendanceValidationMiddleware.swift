//
//  AttendanceValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 18.04.2025.
//

import Vapor
import Domain

public struct AttendanceValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        do {
            let json = try request.content.decode([String: String].self)
            if let membershipId = json["membershipId"] {
                guard
                    UUID(uuidString: membershipId) != nil
                else { throw AttendanceError.invalidMembershipId }
            }
            if let trainingId = json["trainingId"] {
                guard
                    UUID(uuidString: trainingId) != nil
                else { throw AttendanceError.invalidTrainingId }
            }
            if let status = json["status"] {
                guard
                    AttendanceValidator.validate(status: status)
                else { throw AttendanceError.invalidStatus }
            }

            return try await next.respond(to: request)
        } catch { throw error }
    }
}
