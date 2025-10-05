//
//  HasherServiceFake.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 17.09.2025.
//

@testable import Domain

final class IHasherServiceFake: IHasherService {
    func hash(_ password: String) throws -> String {
        return "HASHED:\(password)"
    }

    func verify(_ password: String, created hash: String) throws -> Bool {
        return hash == "HASHED:\(password)"
    }
}
