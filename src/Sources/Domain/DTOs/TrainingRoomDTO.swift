//
//  TrainingRoomDTO.swift
//  Backend
//
//  Created by Цховребова Яна on 27.03.2025.
//

import Vapor

public struct TrainingRoomDTO: Content {
    public let id: UUID
    public let name: String
    public let capacity: Int

    public init(
        id: UUID,
        name: String,
        capacity: Int
    ) {
        self.id = id
        self.name = name
        self.capacity = capacity
    }
}

// MARK: - Init from Model

extension TrainingRoomDTO {
    public init(from trainingRoom: TrainingRoom) {
        self.id = trainingRoom.id
        self.name = trainingRoom.name
        self.capacity = trainingRoom.capacity
    }
}

// MARK: - Equatable

extension TrainingRoomDTO: Equatable {
    public static func == (
        lhs: TrainingRoomDTO,
        rhs: TrainingRoomDTO
    ) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.capacity == rhs.capacity
    }
}

// MARK: - Update

public struct TrainingRoomUpdateDTO: Content {
    public let name: String?
    public let capacity: Int?
}

// MARK: - Create

public struct TrainingRoomCreateDTO: Content {
    public let name: String
    public let capacity: Int
}
