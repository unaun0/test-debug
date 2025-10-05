//
//  IUserSelfService.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 02.09.2025.
//

import Vapor

public protocol IUserSelfService: Sendable {
    func getMyProfile(id: UUID) async throws -> User?
    func updateMyProfile(id: UUID, data: UserSelfUpdateDTO) async throws -> User?
    func deleteMyProfile(id: UUID) async throws
}
