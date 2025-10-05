//
//  UserSelfService.swift
//  Backend
//
//  Created by Цховребова Яна on 04.05.2025.
//

import Vapor

public final class UserSelfService {
    private let userService: IUserService
    
    public init(userService: IUserService) {
        self.userService = userService
    }
}

// MARK: - IUserSelfService

extension UserSelfService: IUserSelfService {
    public func getMyProfile(id: UUID) async throws -> User? {
        guard let user = try await userService.find(id: id) else {
            throw UserError.userNotFound
        }
        return user
    }

    public func updateMyProfile(id: UUID, data: UserSelfUpdateDTO) async throws -> User? {
        guard let updated = try await userService.update(
            id: id,
            with: UserUpdateDTO(from: data)
        ) else {
            throw UserError.userNotFound
        }
        return updated
    }

    public func deleteMyProfile(id: UUID) async throws {
        try await userService.delete(id: id)
    }
}
