//
//  TrainingRoomEntity.swift
//  Backend
//
//  Created by Цховребова Яна on 13.04.2025.
//

import Fluent
import Vapor
import Domain

public final class TrainingRoomDBDTO: Model {
    public static let schema = "TrainingRoom"

    @ID(custom: "id")
    public var id: UUID?

    @Field(key: "name")
    public var name: String

    @Field(key: "capacity")
    public var capacity: Int

    public init() {}
}

// MARK: - Convenience Initializator

extension TrainingRoomDBDTO {
    public convenience init(
        id: UUID? = nil,
        name: String,
        capacity: Int
    ) {
        self.init()
        
        self.id = id
        self.name = name
        self.capacity = capacity
    }
}

// MARK: - Sendable

extension TrainingRoomDBDTO: @unchecked Sendable {}

// MARK: - Content

extension TrainingRoomDBDTO: Content {}

// MARK: - From / To Model

extension TrainingRoomDBDTO {
    public convenience init(from trainingRoom: TrainingRoom) {
        self.init()
        
        self.id = trainingRoom.id
        self.name = trainingRoom.name
        self.capacity = trainingRoom.capacity
    }

    public func toTrainingRoom() -> TrainingRoom? {
        guard let id = self.id else { return nil }

        return TrainingRoom(
            id: id,
            name: name,
            capacity: capacity
        )
    }
}
