//
//  ITrainerSelfService.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 02.09.2025.
//

import Vapor

public protocol ITrainerSelfService: Sendable {
    func getProfile(userId: UUID) async throws -> Trainer?
}
