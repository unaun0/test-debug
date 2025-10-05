//
//  AttendanceCreateValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 18.04.2025.
//

import Vapor
import Domain

public struct AttendanceCreateValidationMiddleware: AsyncMiddleware {
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        do {
            let json = try request.content.decode([String: String].self)
            guard
                let membershipId = json["membershipId"],
                UUID(uuidString: membershipId) != nil
            else { throw AttendanceError.invalidMembershipId }
            guard
                let trainingId = json["trainingId"],
                UUID(uuidString: trainingId) != nil
            else { throw AttendanceError.invalidTrainingId }
            guard
                let status = json["status"],
                AttendanceValidator.validate(status: status)
            else { throw AttendanceError.invalidStatus }

            return try await next.respond(to: request)
        } catch { throw error }
    }
    
    public init() {}
}
