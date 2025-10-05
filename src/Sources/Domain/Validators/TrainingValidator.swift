//
//  TrainingValidator.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Foundation

public struct TrainingValidator {
    public static func validate(date: Date) -> Bool {
        date >= Calendar.current.startOfDay(for: Date())
    }
}
