//
//  IAuthService.swift
//  Backend
//
//  Created by Цховребова Яна on 27.03.2025.
//

public protocol IAuthService: Sendable {
    func register(_ data: RegisterDTO) async throws -> User?
    func login(_ data: LoginDTO) async throws -> User?
}
