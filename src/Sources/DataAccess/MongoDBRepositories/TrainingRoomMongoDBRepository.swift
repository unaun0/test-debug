//
//  TrainingRoomMongoDBRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 13.04.2025.
//

import Fluent
import Vapor
import Domain

public final class TrainingRoomMongoDBRepository {
    private let db: Database
    
    public init(db: Database) {
        self.db = db
    }
}

// MARK: - ITrainingRoomRepository

extension TrainingRoomMongoDBRepository: ITrainingRoomRepository {
    public func create(_ room: TrainingRoom) async throws {
        try await TrainingRoomMongoDBDTO(from: room).create(on: db)
    }
    
    public func update(_ room: TrainingRoom) async throws {
        guard let existing = try await TrainingRoomMongoDBDTO.find(
                room.id,
                on: db
        ) else {
            throw TrainingRoomError.trainingRoomNotFound
        }
        
        existing.name = room.name
        existing.capacity = room.capacity
        
        try await existing.update(on: db)
    }
    
    public func delete(id: UUID) async throws {
        guard let room = try await TrainingRoomMongoDBDTO.find(
                id,
                on: db
        ) else {
            throw TrainingRoomError.trainingRoomNotFound
        }
        
        try await room.delete(on: db)
    }
    
    public func find(id: UUID) async throws -> TrainingRoom? {
        try await TrainingRoomMongoDBDTO.find(
            id,
            on: db
        )?.toTrainingRoom()
    }
    
    public func find(name: String) async throws -> TrainingRoom? {
        try await TrainingRoomMongoDBDTO.query(
            on: db
        ).filter(
            \.$name == name
        ).first()?.toTrainingRoom()
    }
    
    public func find(capacity: Int) async throws -> [TrainingRoom] {
        try await TrainingRoomMongoDBDTO.query(
            on: db
        ).filter(
            \.$capacity == capacity
        ).all().compactMap { $0.toTrainingRoom() }
    }
    
    public func findAll() async throws -> [TrainingRoom] {
        try await TrainingRoomMongoDBDTO.query(
            on: db
        ).all().compactMap { $0.toTrainingRoom() }
    }
}
