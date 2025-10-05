//
//  ITrainerUserService.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 02.09.2025.
//

import Vapor

public protocol ITrainerUserService: Sendable {
    func findTrainer(byID id: UUID) async throws -> (Trainer?, User?)
}
