//
//  MembershipTypeValidator.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Foundation

public struct MembershipTypeValidator {
    public static let maxNameLength = 256

    private static func validate(UIntValue: Int) -> Bool {
        UIntValue > 0
    }

    private static func validate(UDoubleValue: Double) -> Bool {
        UDoubleValue > -Double.ulpOfOne
    }

    public static func validate(name: String) -> Bool {
        (!name.isEmpty) && (name.count < maxNameLength)
    }

    public static func validate(price: Double) -> Bool {
        validate(UDoubleValue: price)
    }

    public static func validate(days: Int) -> Bool {
        validate(UIntValue: days)
    }

    public static func validate(sessions: Int) -> Bool {
        validate(UIntValue: sessions)
    }
}
