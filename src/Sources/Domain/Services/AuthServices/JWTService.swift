//
//  JWTService.swift
//  Backend
//
//  Created by Цховребова Яна on 20.03.2025.
//

import Vapor

public final class JWTService: IJWTService {
    private let expirationTime: TimeInterval

    public init(expirationTime: TimeInterval) {
        self.expirationTime = expirationTime
    }

    public func generateToken(
        for uuid: UUID,
        req: Request
    )
        throws -> String
    {
        try req.jwt.sign(
            AuthPayload(
                id: uuid,
                exp: .init(value: Date().addingTimeInterval(self.expirationTime))
            )
        )
    }
}

extension JWTService: @unchecked Sendable {}
