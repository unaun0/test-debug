//
//  IUserTrainerService.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 02.09.2025.
//

import Vapor

public protocol IUserTrainerService: Sendable {
    func findClient(byID id: UUID) async throws -> User?
}
