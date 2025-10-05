//
//  StringExtension.swift
//  Backend
//
//  Created by Цховребова Яна on 29.03.2025.
//

import Foundation

extension String {
    public func toDate(format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
}
