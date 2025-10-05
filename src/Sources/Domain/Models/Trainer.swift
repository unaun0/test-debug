//
//  Trainer.swift
//  Backend
//
//  Created by Цховребова Яна on 11.03.2025.
//

import Vapor

// MARK: - Trainer

public final class Trainer: BaseModel {
    public var id: UUID
    public var userId: UUID
    public var description: String

    public init(
        id: UUID = UUID(),
        userId: UUID,
        description: String
    ) {
        self.id = id
        self.userId = userId
        self.description = description
    }
}

// MARK: - Trainer Equatable

extension Trainer: Equatable {
    public static func == (lhs: Trainer, rhs: Trainer) -> Bool {
        return lhs.id == rhs.id
            && lhs.userId == rhs.userId
            && lhs.description == rhs.description
    }
}

// MARK: - Trainer Sendable

extension Trainer: @unchecked Sendable {}
