//
//  UserTrainerService.swift
//  Backend
//
//  Created by Цховребова Яна on 04.05.2025.
//

import Vapor

public final class UserTrainerService {
    private let service: IUserService
    
    public init(userService: IUserService) {
        self.service = userService
    }
}

// MARK: - IUserTrainerService

extension UserTrainerService: IUserTrainerService {
    public func findClient(byID id: UUID) async throws -> User? {
        try await service.find(id: id)
    }
}
