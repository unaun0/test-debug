//
//  TrainerRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 13.04.2025.
//

import Fluent
import Vapor
import Domain

public final class TrainerRepository {
    private let db: Database

    public init(db: Database) {
        self.db = db
    }
}

// MARK: - ITrainerRepository

extension TrainerRepository: ITrainerRepository {
    public func create(_ trainer: Trainer) async throws {
        try await TrainerDBDTO(from: trainer).create(on: db)
    }

    public func update(_ trainer: Trainer) async throws {
        guard
            let existing = try await TrainerDBDTO.find(
                trainer.id,
                on: db
            )
        else {
            throw TrainerRepositoryError.trainerNotFound
        }

        existing.userId = trainer.userId
        existing.description = trainer.description

        try await existing.update(on: db)
    }

    public func delete(id: UUID) async throws {
        guard
            let role = try await TrainerDBDTO.find(
                id,
                on: db
            )
        else {
            throw TrainerRepositoryError.trainerNotFound
        }

        try await role.delete(on: db)
    }

    public func find(id: UUID) async throws -> Trainer? {
        try await TrainerDBDTO.find(id, on: db)?.toTrainer()
    }

    public func find(userId: UUID) async throws -> Trainer? {
        try await TrainerDBDTO.query(
            on: db
        ).filter(
            \.$userId == userId
        ).first()?.toTrainer()
    }

    public func findAll() async throws -> [Trainer] {
        try await TrainerDBDTO.query(
            on: db
        ).all().compactMap { $0.toTrainer() }
    }
}

public enum TrainerRepositoryError: Error, LocalizedError {
    case trainerNotFound

    public var errorDescription: String? {
        switch self {
        case .trainerNotFound:
            return "Тренер не найден."
        }
    }
}
