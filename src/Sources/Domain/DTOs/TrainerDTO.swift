//
//  TrainerDTO.swift
//  Backend
//
//  Created by Цховребова Яна on 26.03.2025.
//

import Vapor

public struct TrainerDTO: Content {
    public let id: UUID
    public let userId: UUID
    public let description: String

    public init(
        id: UUID,
        userId: UUID,
        description: String
    ) {
        self.id = id
        self.userId = userId
        self.description = description
    }
}

// MARK: - Init from Model

extension TrainerDTO {
    public init(from trainer: Trainer) {
        self.id = trainer.id
        self.userId = trainer.userId
        self.description = trainer.description
    }
}

// MARK: - Equatable

extension TrainerDTO: Equatable {
    public static func == (
        lhs: TrainerDTO,
        rhs: TrainerDTO
    ) -> Bool {
        return lhs.id == rhs.id
            && lhs.userId == rhs.userId
            && lhs.description == rhs.description
    }
}

// MARK: - Update

public struct TrainerUpdateDTO: Content {
    public let userId: UUID?
    public let description: String?
}

// MARK: - Create

public struct TrainerCreateDTO: Content {
    public let userId: UUID
    public let description: String
}

// MARK: - Trainer Info DTO for Users

public struct TrainerInfoDTO: Content {
    public let id: UUID
    public let userId: UUID
    public let description: String
    public let firstName: String
    public let lastName: String

    public init(
        id: UUID,
        userId: UUID,
        description: String,
        firstName: String,
        lastName: String
    ) {
        self.id = id
        self.userId = userId
        self.description = description
        self.firstName = firstName
        self.lastName = lastName
    }
}
