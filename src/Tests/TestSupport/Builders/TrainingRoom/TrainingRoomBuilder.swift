//
//  TrainingRoomBuilder.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 07.09.2025.
//

import Vapor
@testable import Domain

final class TrainingRoomBuilder {
    private var id = UUID()
    private var name = "Тренажерный зал"
    private var capacity = 20

    func withId(_ id: UUID) -> Self { self.id = id; return self }
    func withName(_ name: String) -> Self { self.name = name; return self }
    func withCapacity(_ capacity: Int) -> Self { self.capacity = capacity; return self }

    func build() -> TrainingRoom {
        TrainingRoom(
            id: id,
            name: name,
            capacity: capacity
        )
    }
}
