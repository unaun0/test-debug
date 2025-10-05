//
//  TrainingRoomValidator.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Foundation

public struct TrainingRoomValidator {
    public static let maxNameLength = 256
    
    public static func validate(name: String) -> Bool {
        (!name.isEmpty) && (name.count < maxNameLength)
    }

    public static func validate(capacity: Int) -> Bool {
        capacity > 0
    }
}

