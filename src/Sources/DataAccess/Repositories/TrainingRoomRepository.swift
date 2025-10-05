//
//  TrainingRoomRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 13.04.2025.
//

import Fluent
import Vapor
import Domain

public final class TrainingRoomRepository {
    private let db: Database
    
    public init(db: Database) {
        self.db = db
    }
}

// MARK: - ITrainingRoomRepository

extension TrainingRoomRepository: ITrainingRoomRepository {
    public func create(_ room: TrainingRoom) async throws {
        try await TrainingRoomDBDTO(from: room).create(on: db)
    }
    
    public func update(_ room: TrainingRoom) async throws {
        guard let existing = try await TrainingRoomDBDTO.find(
                room.id,
                on: db
        ) else {
            throw TrainingRoomRepositoryError.trainingRoomNotFound
        }
        
        existing.name = room.name
        existing.capacity = room.capacity
        
        try await existing.update(on: db)
    }
    
    public func delete(id: UUID) async throws {
        guard let room = try await TrainingRoomDBDTO.find(
                id,
                on: db
        ) else {
            throw TrainingRoomRepositoryError.trainingRoomNotFound
        }
        
        try await room.delete(on: db)
    }
    
    public func find(id: UUID) async throws -> TrainingRoom? {
        try await TrainingRoomDBDTO.find(
            id,
            on: db
        )?.toTrainingRoom()
    }
    
    public func find(name: String) async throws -> TrainingRoom? {
        try await TrainingRoomDBDTO.query(
            on: db
        ).filter(
            \.$name == name
        ).first()?.toTrainingRoom()
    }
    
    public func find(capacity: Int) async throws -> [TrainingRoom] {
        try await TrainingRoomDBDTO.query(
            on: db
        ).filter(
            \.$capacity == capacity
        ).all().compactMap { $0.toTrainingRoom() }
    }
    
    public func findAll() async throws -> [TrainingRoom] {
        try await TrainingRoomDBDTO.query(
            on: db
        ).all().compactMap { $0.toTrainingRoom() }
    }
}

public enum TrainingRoomRepositoryError: Error, LocalizedError {
    case trainingRoomNotFound

    public var errorDescription: String? {
        switch self {
        case .trainingRoomNotFound:
            return "Зал не найден."
        }
    }
}
