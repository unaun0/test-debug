//
//  ITrainingUserService.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 02.09.2025.
//

import Vapor

public protocol ITrainingUserService: Sendable {
    func findAvailableTrainings() async throws -> [TrainingInfoDTO]
}
