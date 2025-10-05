//
//  TrainerMongoDBRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 29.05.2025.
//

import Vapor
import Fluent
import Domain

public final class TrainerMongoDBRepository: ITrainerRepository {
    private let db: Database

    public init(db: Database) {
        self.db = db
    }

    public func create(_ trainer: Trainer) async throws {
        let dto = TrainerMongoDBDTO(from: trainer)
        try await dto.create(on: db)
    }

    public func update(_ trainer: Trainer) async throws {
        guard let existing = try await TrainerMongoDBDTO.find(trainer.id, on: db) else {
            throw TrainerError.trainerNotFound
        }

        existing.userId = trainer.userId
        existing.description = trainer.description

        try await existing.update(on: db)
    }

    public func delete(id: UUID) async throws {
        guard let existing = try await TrainerMongoDBDTO.find(id, on: db) else {
            throw TrainerError.trainerNotFound
        }
        try await existing.delete(on: db)
    }

    public func find(id: UUID) async throws -> Trainer? {
        guard let dto = try await TrainerMongoDBDTO.find(id, on: db) else {
            return nil
        }
        return dto.toTrainer()
    }

    public func find(userId: UUID) async throws -> Trainer? {
        guard let dto = try await TrainerMongoDBDTO.query(on: db)
            .filter(\.$userId == userId)
            .first() else {
                return nil
        }
        return dto.toTrainer()
    }

    public func findAll() async throws -> [Trainer] {
        let dtos = try await TrainerMongoDBDTO.query(on: db).all()
        return dtos.compactMap { $0.toTrainer() }
    }
}
