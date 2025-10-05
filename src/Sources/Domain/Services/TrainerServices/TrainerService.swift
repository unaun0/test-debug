//
//  TrainerService.swift
//  Backend
//
//  Created by Цховребова Яна on 11.03.2025.
//

import Vapor
import Fluent

public final class TrainerService {
    private let repository: ITrainerRepository
    
    public init(repository: ITrainerRepository) {
        self.repository = repository
    }
}

// MARK: - ITrainerService

extension TrainerService: ITrainerService {
    public func create(_ data: TrainerCreateDTO) async throws -> Trainer? {
        if try await repository.find(userId: data.userId) != nil {
            throw TrainerError.userAlreadyHasTrainer
        }
        let trainer = Trainer(
            id: UUID(),
            userId: data.userId,
            description: data.description
        )
        try await repository.create(trainer)
        
        return trainer
    }

    public func update(id: UUID, with data: TrainerUpdateDTO) async throws -> Trainer? {
        guard
            let trainer = try await repository.find(id: id)
        else {
            throw TrainerError.trainerNotFound
        }
        if let user = data.userId {
            if try await repository.find(userId: user) != nil {
                throw TrainerError.userAlreadyHasTrainer
            }
            trainer.userId = user
        }
        if let description = data.description {
            trainer.description = description
        }
        try await repository.update(trainer)
        
        return trainer
    }

    public func find(id: UUID) async throws -> Trainer? {
        try await repository.find(id: id)
    }

    public func find(userId: UUID) async throws -> Trainer? {
        try await repository.find(userId: userId)
    }

    public func findAll() async throws -> [Trainer] {
        try await repository.findAll()
    }

    public func delete(id: UUID) async throws {
        guard let _ = try await repository.find(id: id) else {
            throw TrainerError.trainerNotFound
        }
        try await repository.delete(id: id)
    }
}
