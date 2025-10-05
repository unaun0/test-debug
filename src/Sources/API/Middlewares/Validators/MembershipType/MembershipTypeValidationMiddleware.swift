//
//  MembershipTypeValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 13.04.2025.
//

import Vapor
import Domain

public struct MembershipTypeValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        do {
            if let name = try? request.content.get(String.self, at: "name") {
                guard
                    MembershipTypeValidator.validate(name: name)
                else {
                    throw MembershipTypeError.invalidName
                }
            }

            if let price = try? request.content.get(Double.self, at: "price") {
                guard
                    MembershipTypeValidator.validate(price: price)
                else { throw MembershipTypeError.invalidPrice }
            }

            if let sessions = try? request.content.get(Int.self, at: "sessions") {
                guard
                    MembershipTypeValidator.validate(sessions: sessions)
                else { throw MembershipTypeError.invalidSessions }
            }

            if let days = try? request.content.get(Int.self, at: "days") {
                guard
                    MembershipTypeValidator.validate(days: days)
                else { throw MembershipTypeError.invalidDays }
            }
            return try await next.respond(to: request)
        } catch {
            throw error
        }
    }
}
