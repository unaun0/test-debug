//
//  TrainingRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 15.04.2025.
//

import Fluent
import Vapor
import Domain

public final class TrainingMongoDBRepository {
    private let db: Database

    public init(db: Database) {
        self.db = db
    }
}

// MARK: - ITrainingRepository

extension TrainingMongoDBRepository: ITrainingRepository {
    public func create(_ training: Training) async throws {
        try await TrainingMongoDBDTO(from: training).create(on: db)
    }

    public func update(_ training: Training) async throws {
        guard
            let existing = try await TrainingMongoDBDTO.find(
                training.id,
                on: db
            )
        else {
            throw TrainingError.trainingNotFound
        }
        existing.roomId = training.roomId
        existing.trainerId = training.trainerId
        existing.date = training.date

        try await existing.update(on: db)
    }

    public func delete(id: UUID) async throws {
        guard
            let training = try await TrainingMongoDBDTO.find(
                id,
                on: db
            )
        else {
            throw TrainingError.trainingNotFound
        }

        try await training.delete(on: db)
    }

    public func find(id: UUID) async throws -> Training? {
        try await TrainingMongoDBDTO.find(
            id,
            on: db
        )?.toTraining()
    }

    public func find(trainerId: UUID) async throws -> [Training] {
        return try await TrainingMongoDBDTO.query(
            on: db
        ).filter(
            \.$trainerId == trainerId
        ).all().compactMap { $0.toTraining() }
    }

    public func find(trainingRoomId: UUID) async throws -> [Training] {
        return try await TrainingMongoDBDTO.query(
            on: db
        ).filter(
            \.$roomId == trainingRoomId
        ).all().compactMap { $0.toTraining() }
    }

    public func find(date: Date) async throws -> [Training] {
        return try await TrainingMongoDBDTO.query(
            on: db
        ).filter(
            \.$date == date
        ).all().compactMap { $0.toTraining() }
    }

    public func findAll() async throws -> [Training] {
        try await TrainingMongoDBDTO.query(
            on: db
        ).all().compactMap { $0.toTraining() }
    }
}
