//
//  TrainingDTO.swift
//  Backend
//
//  Created by Цховребова Яна on 27.03.2025.
//

import Vapor

public struct TrainingDTO: Content {
    public let id: UUID
    public let date: String?
    public let roomId: UUID
    public let trainerId: UUID

    public init(
        id: UUID,
        date: String,
        roomId: UUID,
        trainerId: UUID
    ) {
        self.id = id
        self.date = date
        self.roomId = roomId
        self.trainerId = trainerId
    }
}

// MARK: - Init from Model

extension TrainingDTO {
    public init(from training: Training) {
        self.id = training.id
        self.date = training.date.toString(
            format: "yyyy-MM-dd HH:mm:ss"
        )
        self.roomId = training.roomId
        self.trainerId = training.trainerId
    }
}

// MARK: - Equatable

extension TrainingDTO: Equatable {
    public static func == (
        lhs: TrainingDTO,
        rhs: TrainingDTO
    ) -> Bool {
        return lhs.id == rhs.id
            && lhs.date == rhs.date
            && lhs.roomId == rhs.roomId
            && lhs.trainerId == rhs.trainerId
    }
}

// MARK: - Update

public struct TrainingUpdateDTO: Content {
    public let date: String?
    public let roomId: UUID?
    public let trainerId: UUID?
}

// MARK: - Create

public struct TrainingCreateDTO: Content {
    public let date: String?
    public let roomId: UUID
    public let trainerId: UUID
}

// MARK: - Training Info

public struct TrainingInfoDTO: Content {
    public var id: UUID
    public var date: String
    public var trainer: TrainerInfoDTO
    public var room: TrainingRoomDTO
    
    public init(
        id: UUID,
        date: Date,
        trainer: TrainerInfoDTO,
        room: TrainingRoomDTO
    ) {
        self.id = id
        self.date = date.toString(
            format: "yyyy-MM-dd HH:mm:ss"
        )
        self.room = room
        self.trainer = trainer
    }
}

