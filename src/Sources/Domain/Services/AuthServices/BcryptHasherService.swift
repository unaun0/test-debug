//
//  PasswordHasherService.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Vapor

public final class BcryptHasherService: IHasherService {
    public func hash(_ value: String) throws -> String {
        return try Bcrypt.hash(value)
    }

    public func verify(_ value: String, created hash: String) throws -> Bool {
        return try Bcrypt.verify(value, created: hash)
    }
    
    public init() {}
}

extension BcryptHasherService: @unchecked Sendable { }
