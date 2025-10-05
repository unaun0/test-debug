//
//  TrainerSelfService.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 02.09.2025.
//

import Vapor

public final class TrainerSelfService {
    private let tService: ITrainerService

    public init(
        trainerService: ITrainerService
    ) {
        self.tService = trainerService
    }
}

// MARK: - ITrainerSelfService

extension TrainerSelfService: ITrainerSelfService {
    public func getProfile(userId: UUID) async throws -> Trainer? {
        try await tService.find(userId: userId)
    }
}

