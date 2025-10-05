//
//  MembershipValidator.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Foundation

public struct MembershipValidator {
    public static func validate(sessions: Int) -> Bool {
        sessions >= 0
    }

    public static func validate(date: Date?) -> Bool {
        switch date {
        case (nil):
            return true
        case (let date?):
            return date >= Calendar.current.startOfDay(for: Date())
        }
    }

    public static func validate(startDate: Date?, endDate: Date?) -> Bool {
        switch (startDate, endDate) {
        case (nil, nil):
            return true
        case (let start?, let end?):
            return start <= end
        default:
            return false
        }
    }
}
