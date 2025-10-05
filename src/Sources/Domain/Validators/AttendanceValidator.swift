//
//  AttendanceValidator.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Foundation

public struct AttendanceValidator {
    public static func validate(status: String) -> Bool {
        AttendanceStatus(rawValue: status) != nil
    }
}
