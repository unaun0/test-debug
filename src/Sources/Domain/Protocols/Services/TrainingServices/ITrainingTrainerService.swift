//
//  ITrainingTrainerService.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 02.09.2025.
//

import Vapor

public protocol ITrainingTrainerService: Sendable {
    func findAvailableTrainings(userId: UUID) async throws -> [TrainingInfoDTO]
    func findAllTrainings(userId: UUID) async throws -> [TrainingInfoDTO]
}
