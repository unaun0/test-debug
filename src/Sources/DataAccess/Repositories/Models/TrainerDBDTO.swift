//
//  TrainerEntity.swift
//  Backend
//
//  Created by Цховребова Яна on 13.04.2025.
//

import Fluent
import Vapor
import Domain

public final class TrainerDBDTO: Model {
    public static let schema = "Trainer"

    @ID(custom: "id")
    public var id: UUID?

    @Field(key: "user_id")
    public var userId: UUID

    @Field(key: "description")
    public var description: String

    public init() {}
}

// MARK: - Convenience Initializator

extension TrainerDBDTO {
    public convenience init(
        id: UUID? = nil,
        userId: UUID,
        description: String
    ) {
        self.init()
        
        self.id = id
        self.userId = userId
        self.description = description
    }
}

// MARK: - Sendable

extension TrainerDBDTO: @unchecked Sendable {}

// MARK: - Content

extension TrainerDBDTO: Content {}

// MARK: - From / To Model

extension TrainerDBDTO {
    public convenience init(from trainer: Trainer) {
        self.init()
        
        self.id = trainer.id
        self.userId = trainer.userId
        self.description = trainer.description
    }

    public func toTrainer() -> Trainer? {
        guard let id = self.id else { return nil }
        
        return Trainer(
            id: id,
            userId: userId,
            description: description
        )
    }
}
