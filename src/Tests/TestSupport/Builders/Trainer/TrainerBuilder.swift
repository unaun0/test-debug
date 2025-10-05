//
//  TrainerBuilder.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 07.09.2025.
//

import Foundation
@testable import Domain


public final class TrainerBuilder {
    private var id: UUID = UUID()
    private var userId: UUID = UUID()
    private var description: String = "Default trainer description"

    public init() {}

    public func withId(_ id: UUID) -> Self { self.id = id; return self }
    public func withUserId(_ userId: UUID) -> Self { self.userId = userId; return self }
    public func withDescription(_ description: String) -> Self { self.description = description; return self }

    public func build() -> Trainer {
        return Trainer(
            id: id,
            userId: userId,
            description: description
        )
    }
}
