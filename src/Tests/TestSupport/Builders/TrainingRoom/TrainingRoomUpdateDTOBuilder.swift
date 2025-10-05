//
//  TrainingRoomUpdateDTOBuilder.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 07.09.2025.
//

@testable import Domain

final class TrainingRoomUpdateDTOBuilder {
    private var name: String? = nil
    private var capacity: Int? = nil

    func withName(_ name: String) -> Self { self.name = name; return self }
    func withCapacity(_ capacity: Int) -> Self { self.capacity = capacity; return self }

    func build() -> TrainingRoomUpdateDTO {
        TrainingRoomUpdateDTO(
            name: name,
            capacity: capacity
        )
    }
}
