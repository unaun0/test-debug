//
//  TrainerCreateDTOBuilder.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 07.09.2025.
//

import Foundation
@testable import Domain


public final class TrainerCreateDTOBuilder {
    private var userId: UUID = UUID()
    private var description: String = "Default trainer description"

    public init() {}

    public func withUserId(_ userId: UUID) -> Self { self.userId = userId; return self }
    public func withDescription(_ description: String) -> Self { self.description = description; return self }

    public func build() -> TrainerCreateDTO {
        return TrainerCreateDTO(
            userId: userId,
            description: description
        )
    }
}
