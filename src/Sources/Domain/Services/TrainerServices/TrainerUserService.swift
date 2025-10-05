//
//  TrainerUserService.swift
//  Backend
//
//  Created by Цховребова Яна on 10.05.2025.
//

import Vapor

public final class TrainerUserService {
    private let tService: ITrainerService
    private let uService: IUserService
    
    public init(
        trainerService: ITrainerService,
        userService: IUserService
    ) {
        self.tService = trainerService
        self.uService = userService
    }
}

// MARK: - ITrainerUserService

extension TrainerUserService: ITrainerUserService {
    public func findTrainer(byID id: UUID) async throws -> (Trainer?, User?) {
        let trainer = try await tService.find(id: id)
        var user: User? = nil
        if let userId = trainer?.userId {
            user = try await uService.find(id: userId)
        }
        return (trainer, user)
    }
    
    public func findTrainer(byUserID userID: UUID) async throws -> (Trainer?, User?) {
        let trainer = try await tService.find(userId: userID)
        var user: User? = nil
        if trainer != nil {
            user = try await uService.find(id: userID)
        }
        return (trainer, user)
    }
}
