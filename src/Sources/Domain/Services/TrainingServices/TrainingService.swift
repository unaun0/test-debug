//
//  TrainingService.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Fluent
import Vapor

public final class TrainingService {
    private let repository: ITrainingRepository
    
    public init(repository: ITrainingRepository) {
        self.repository = repository
    }
}

// MARK: - ITrainingService

extension TrainingService: ITrainingService {
    public func create(_ data: TrainingCreateDTO) async throws -> Training? {
        guard let date = data.date?.toDate(
            format: ValidationRegex.DateFormat.format
        ) else {
            throw TrainingError.invalidDate
        }
        let training = Training(
            id: UUID(),
            date: date,
            roomId: data.roomId,
            trainerId: data.trainerId
        )
        try await repository.create(training)
        
        return training
    }

    public func update(
        id: UUID,
        with data: TrainingUpdateDTO
    ) async throws -> Training? {
        guard let training = try await repository.find(id: id) else {
            throw TrainingError.trainerNotFound
        }
        if let dateString = data.date {
            guard let date = dateString.toDate(
                format: ValidationRegex.DateFormat.format
            ) else {
                throw TrainingError.invalidDate
            }
            training.date = date
        }
        if let room = data.roomId {
            training.roomId = room
        }
        if let trainer = data.trainerId {
            training.trainerId = trainer
        }
        try await repository.update(training)
        
        return training
    }

    public func find(id: UUID) async throws -> Training? {
        try await repository.find(id: id)
    }

    public func find(trainerId: UUID) async throws -> [Training] {
        try await repository.find(trainerId: trainerId)
    }

    public func find(trainingRoomId: UUID) async throws -> [Training] {
        try await repository.find(
            trainingRoomId: trainingRoomId
        )
    }

    public func find(date: Date) async throws -> [Training] {
        try await repository.find(date: date)
    }

    public func findAll() async throws -> [Training] {
        try await repository.findAll()
    }

    public func delete(id: UUID) async throws {
        guard
            let _ = try await repository.find(id: id)
        else {
            throw TrainingError.trainingNotFound
        }
        try await repository.delete(id: id)
    }
}
