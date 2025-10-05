//
//  Training.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Vapor

// MARK: - Training

public final class Training: BaseModel {
    public var id: UUID
    public var date: Date
    public var roomId: UUID
    public var trainerId: UUID

    public init(
        id: UUID = UUID(),
        date: Date,
        roomId: UUID,
        trainerId: UUID
    ) {
        self.id = id
        self.date = date
        self.roomId = roomId
        self.trainerId = trainerId
    }
}

// MARK: - Training Equatable

extension Training: Equatable {
    public static func == (lhs: Training, rhs: Training) -> Bool {
        return lhs.id == rhs.id
            && lhs.date == rhs.date
            && lhs.trainerId == rhs.trainerId
            && lhs.roomId == rhs.roomId
    }
}

// MARK: - Training Sendable

extension Training: @unchecked Sendable {}
