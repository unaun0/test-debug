//
//  UserService.swift
//  Backend
//
//  Created by Цховребова Яна on 11.03.2025.
//

import Vapor

public final class UserService {
    private let userRepository: IUserRepository
    private let passwordHasher: IHasherService
    
    public init(
        userRepository: IUserRepository,
        passwordHasher: IHasherService
    ) {
        self.userRepository = userRepository
        self.passwordHasher = passwordHasher
    }
}

// MARK: - IUserService

extension UserService: IUserService {
    public func create(_ data: UserCreateDTO) async throws -> User? {
        if try await userRepository.find(email: data.email) != nil {
            throw UserError.emailAlreadyExists
        }
        if try await userRepository.find(phoneNumber: data.phoneNumber) != nil {
            throw UserError.phoneNumberAlreadyExists
        }
        guard let date = data.birthDate.toDate(
            format: ValidationRegex.DateFormat.format
        ) else {
            throw UserError.invalidBirthDate
        }
        let user = User(
            id: UUID(),
            email: data.email,
            phoneNumber: data.phoneNumber,
            password: try passwordHasher.hash(data.password),
            firstName: data.firstName,
            lastName: data.lastName,
            birthDate: date,
            gender: data.gender,
            role: data.role
        )
        try await userRepository.create(user)

        return user
    }
    
    public func find(role: String) async throws -> [User] {
        try await userRepository.find(role: role)
    }

    public func update(id: UUID, with data: UserUpdateDTO) async throws -> User? {
        guard var user = try await userRepository.find(id: id) else {
            throw UserError.userNotFound
        }
        if let firstName = data.firstName {
            user.firstName = firstName
        }
        if let lastName = data.lastName {
            user.lastName = lastName
        }
        if let email = data.email {
            if try await userRepository.find(email: email) != nil {
                throw UserError.emailAlreadyExists
            }
            user.email = email
        }
        if let phoneNumber = data.phoneNumber {
            if try await userRepository.find(
                phoneNumber: phoneNumber
            ) != nil {
                throw UserError.phoneNumberAlreadyExists
            }
            user.phoneNumber = phoneNumber
        }
        if let password = data.password {
            user.password = try passwordHasher.hash(password)
        }
        if let birthDate = data.birthDate {
            guard let date = birthDate.toDate(
                format: ValidationRegex.DateFormat.format
            )
            else { throw UserError.invalidBirthDate }
            user.birthDate = date
        }
        if let gender = data.gender {
            user.gender = gender
        }
        if let role = data.role {
            user.role = role
        }
        try await userRepository.update(user)

        return user
    }

    public func find(email: String) async throws -> User? {
        try await userRepository.find(email: email)
    }

    public func find(id: UUID) async throws -> User? {
        try await userRepository.find(id: id)
    }

    public func find(phoneNumber: String) async throws -> User? {
        try await userRepository.find(phoneNumber: phoneNumber)
    }

    public func delete(id: UUID) async throws {
        guard let _ = try await userRepository.find(id: id) else {
            throw UserError.userNotFound
        }
        try await userRepository.delete(id: id)
    }

    public func findAll() async throws -> [User] {
        try await userRepository.findAll()
    }
}
