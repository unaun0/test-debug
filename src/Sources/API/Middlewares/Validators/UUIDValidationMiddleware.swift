//
//  UUIDValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 11.04.2025.
//

import Vapor
import Domain

public struct UUIDValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        let parameterNames = request.parameters.allNames
        for name in parameterNames {
            let lowercaseName = name.lowercased()
            if lowercaseName == "id" || lowercaseName.hasSuffix("-id") {
                let value = request.parameters.get(name) ?? ""
                guard !value.isEmpty else {
                    throw Abort(
                        .badRequest,
                        reason:
                            "Параметр '\(name)' обязателен и не может быть пустым."
                    )
                }
                guard UUID(uuidString: value) != nil else {
                    throw Abort(
                        .badRequest,
                        reason:
                            "Параметр '\(name)' должен быть корректным UUID."
                    )
                }
            }
        }
        return try await next.respond(to: request)
    }
}
