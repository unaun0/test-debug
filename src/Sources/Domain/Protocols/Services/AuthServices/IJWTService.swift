//
//  IJWTService.swift
//  Backend
//
//  Created by Цховребова Яна on 20.03.2025.
//

import Vapor

public protocol IJWTService: Sendable {
    func generateToken(for uuid: UUID, req: Request) throws -> String
}
