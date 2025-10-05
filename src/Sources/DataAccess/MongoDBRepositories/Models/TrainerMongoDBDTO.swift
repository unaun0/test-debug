//
//  Untitled.swift
//  Backend
//
//  Created by Цховребова Яна on 29.05.2025.
//

import Fluent
import Vapor
import Domain

public final class TrainerMongoDBDTO: Model, @unchecked Sendable {
    public static let schema = "Trainer"

    @ID(custom: "_id")
    public var id: UUID?

    @Field(key: "user_id")
    public var userId: UUID

    @Field(key: "description")
    public var description: String

    public init() {}

    public init(
        id: UUID? = nil,
        userId: UUID,
        description: String
    ) {
        self.id = id
        self.userId = userId
        self.description = description
    }
}

extension TrainerMongoDBDTO {
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
