//
//  AuthService.swift
//  Backend
//
//  Created by Цховребова Яна on 27.03.2025.
//

public final class AuthService: IAuthService {
    private let userService: IUserService
    private let passwordHasher: IHasherService
    
    public init(
        userService: IUserService,
        passwordHasher: IHasherService
    ) {
        self.userService = userService
        self.passwordHasher = passwordHasher
    }
    
    public func register(_ data: RegisterDTO) async throws -> User? {
        try await userService.create(UserCreateDTO(from: data))
    }
    
    public func login(_ data: LoginDTO) async throws -> User? {
        var foundUser = try await userService.find(email: data.login)
        if foundUser == nil {
            foundUser = try await userService.find(phoneNumber: data.login)
        }
        guard let user = foundUser else {
            throw UserError.userNotFound
        }
        if try !passwordHasher.verify(data.password, created: user.password) {
            throw UserError.invalidPassword
        }

        return user
    }
}
