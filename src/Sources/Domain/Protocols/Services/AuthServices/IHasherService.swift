//
//  IPasswordHasherService.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

/// @mockable
public protocol IHasherService: Sendable {
    func hash(_ value: String) throws -> String
    func verify(_ value: String, created hash: String) throws -> Bool
}
