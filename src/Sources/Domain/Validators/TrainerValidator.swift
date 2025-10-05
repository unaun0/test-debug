//
//  TrainerValidator.swift
//  Backend
//
//  Created by Цховребова Яна on 11.03.2025.
//

import Foundation

public struct TrainerValidator {
    public static let maxDescriptionLength = 512

    public static func validate(description: String) -> Bool {
        description.count < maxDescriptionLength
    }
}
