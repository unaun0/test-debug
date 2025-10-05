//
//  TrainingRoom.swift
//  Backend
//
//  Created by Цховребова Яна on 12.03.2025.
//

import Vapor

// MARK: - TrainingRoom

public final class TrainingRoom: BaseModel {
    public var id: UUID
    public var name: String
    public var capacity: Int

    public init(
        id: UUID = UUID(),
        name: String,
        capacity: Int
    ) {
        self.id = id
        self.name = name
        self.capacity = capacity
    }
}

// MARK: - TrainingRoom Equatable

extension TrainingRoom: Equatable {
    public static func == (lhs: TrainingRoom, rhs: TrainingRoom) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.capacity == rhs.capacity
    }
}

// MARK: - TrainingRoom Sendable

extension TrainingRoom: @unchecked Sendable {}

