//
//  TrainingRoomService.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Fluent
import Vapor

public final class TrainingRoomService {
    private let repository: ITrainingRoomRepository
    
    public init(repository: ITrainingRoomRepository) {
        self.repository = repository
    }
}

// MARK: - ITrainingRoomService

extension TrainingRoomService: ITrainingRoomService {
    public func create(_ data: TrainingRoomCreateDTO) async throws -> TrainingRoom? {
        if try await repository.find(name: data.name) != nil {
            throw TrainingRoomError.nameAlreadyExists
        }
        let room = TrainingRoom(
            id: UUID(),
            name: data.name,
            capacity: data.capacity
        )
        try await repository.create(room)
        
        return room
    }

    public func update(id: UUID, with data: TrainingRoomUpdateDTO) async throws -> TrainingRoom? {
        guard
            let room = try await repository.find(id: id)
        else {
            throw TrainingRoomError.trainingRoomNotFound
        }
        if let name = data.name {
            if try await repository.find(name: name) != nil {
                throw TrainingRoomError.nameAlreadyExists
            }
            room.name = name
        }
        if let capacity = data.capacity {
            room.capacity = capacity
        }
        try await repository.update(room)
        
        return room
    }

    public func find(id: UUID) async throws -> TrainingRoom? {
        return try await repository.find(id: id)
    }

    public func find(name: String) async throws -> TrainingRoom? {
        return try await repository.find(name: name)
    }

    public func find(capacity: Int) async throws -> [TrainingRoom] {
        return try await repository.find(capacity: capacity)
    }

    public func findAll() async throws -> [TrainingRoom] {
        try await repository.findAll()
    }

    public func delete(id: UUID) async throws {
        guard let _ = try await repository.find(id: id) else {
            throw TrainingRoomError.trainingRoomNotFound
        }
        try await repository.delete(id: id)
    }
}
