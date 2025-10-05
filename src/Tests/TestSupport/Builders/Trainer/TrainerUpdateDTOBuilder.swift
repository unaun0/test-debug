//
//  TrainerUpdateDTOBuilder.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 07.09.2025.
//

import Foundation
@testable import Domain


public final class TrainerUpdateDTOBuilder {
    private var userId: UUID? = nil
    private var description: String? = nil

    public init() {}

    public func withUserId(_ userId: UUID?) -> Self { self.userId = userId; return self }
    public func withDescription(_ description: String?) -> Self { self.description = description; return self }

    public func build() -> TrainerUpdateDTO {
        return TrainerUpdateDTO(
            userId: userId,
            description: description
        )
    }
}
