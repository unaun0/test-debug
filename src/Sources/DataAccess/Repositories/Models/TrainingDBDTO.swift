//
//  TrainingEntity.swift
//  Backend
//
//  Created by Цховребова Яна on 15.04.2025.
//

import Fluent
import Vapor
import Domain

public final class TrainingDBDTO: Model {
    public static let schema = "Training"

    @ID(custom: "id")
    public var id: UUID?

    @Field(key: "date")
    public var date: Date

    @Field(key: "room_id")
    public var roomId: UUID

    @Field(key: "trainer_id")
    public var trainerId: UUID

    public init() {}
}

// MARK: - Convenience Initializator

extension TrainingDBDTO {
    public convenience init(
        id: UUID? = nil,
        date: Date,
        roomId: UUID,
        trainerId: UUID
    ) {
        self.init()
        
        self.id = id
        self.date = date
        self.roomId = roomId
        self.trainerId = trainerId
    }
}

// MARK: - Sendable

extension TrainingDBDTO: @unchecked Sendable {}

// MARK: - Content

extension TrainingDBDTO: Content {}

// MARK: - From / To Model

extension TrainingDBDTO {
    public convenience init(from training: Training) {
        self.init()
        
        self.id = training.id
        self.date = training.date
        self.roomId = training.roomId
        self.trainerId = training.trainerId
    }

    public func toTraining() -> Training? {
        guard let id = self.id else { return nil }

        return Training(
            id: id,
            date: date,
            roomId: roomId,
            trainerId: trainerId
        )
    }
}
