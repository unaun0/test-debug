//
//  CreateUserDTO.swift
//  FitClubApp
//
//  Created by Цховребова Яна on 25.02.2025.
//

import Vapor

public struct UserDTO: Content {
    public let id: UUID
    public let email: String
    public let phoneNumber: String
    public let firstName: String
    public let lastName: String
    public let birthDate: String
    public let gender: UserGender

    public init(
        id: UUID,
        email: String,
        phoneNumber: String,
        firstName: String,
        lastName: String,
        birthDate: String,
        gender: UserGender
    ) {
        self.id = id
        self.email = email
        self.phoneNumber = phoneNumber
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.gender = gender
    }
}

// MARK: - Init from Model

extension UserDTO {
    public init(from user: User) {
        self.id = user.id
        self.email = user.email
        self.phoneNumber = user.phoneNumber
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.birthDate = user.birthDate.toString(
            format: ValidationRegex.DateFormat.format
        )
        self.gender = user.gender
    }
}

// MARK: - Equatable

extension UserDTO: Equatable {
    public static func == (lhs: UserDTO, rhs: UserDTO) -> Bool {
        return lhs.id == rhs.id
            && lhs.email == rhs.email
            && lhs.phoneNumber == rhs.phoneNumber
            && lhs.firstName == rhs.firstName
            && lhs.lastName == rhs.lastName
            && lhs.gender == rhs.gender
            && lhs.birthDate == rhs.birthDate
    }
}

// MARK: - Admin User

public struct UserAdminDTO: Content {
    public let id: UUID
    public let email: String
    public let phoneNumber: String
    public let password: String
    public let firstName: String
    public let lastName: String
    public let birthDate: String
    public let gender: UserGender
    public let role: UserRoleName
}

// MARK: - Admin User from User Model

extension UserAdminDTO {
    public init(from user: User) {
        self.id = user.id
        self.email = user.email
        self.phoneNumber = user.phoneNumber
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.birthDate = user.birthDate.toString(
            format: ValidationRegex.DateFormat.format
        )
        self.gender = user.gender
        self.role = user.role
        self.password = user.password
    }
}

// MARK: - Update

public struct UserSelfUpdateDTO: Content {
    public let email: String?
    public let phoneNumber: String?
    public let password: String?
    public let firstName: String?
    public let lastName: String?
    public let birthDate: String?
    public let gender: UserGender?
}

// MARK: - Admin Update

public struct UserUpdateDTO: Content {
    public let email: String?
    public let phoneNumber: String?
    public let password: String?
    public let firstName: String?
    public let lastName: String?
    public let birthDate: String?
    public let gender: UserGender?
    public let role: UserRoleName?

    public init(
        email: String? = nil,
        phoneNumber: String? = nil,
        password: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        birthDate: String? = nil,
        gender: UserGender? = nil,
        role: UserRoleName? = nil
    ) {
        self.email = email
        self.phoneNumber = phoneNumber
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.gender = gender
        self.role = role
    }
}

extension UserUpdateDTO {
    public init(from selfUpdateDTO: UserSelfUpdateDTO) {
        self.email = selfUpdateDTO.email
        self.phoneNumber = selfUpdateDTO.phoneNumber
        self.password = selfUpdateDTO.password
        self.firstName = selfUpdateDTO.firstName
        self.lastName = selfUpdateDTO.lastName
        self.birthDate = selfUpdateDTO.birthDate
        self.gender = selfUpdateDTO.gender
        self.role = nil
    }
}

// MARK: - Create

public struct UserCreateDTO: Content {
    public let email: String
    public let phoneNumber: String
    public let password: String
    public let firstName: String
    public let lastName: String
    public let birthDate: String
    public let gender: UserGender
    public let role: UserRoleName

    public init(
        email: String,
        phoneNumber: String,
        password: String,
        firstName: String,
        lastName: String,
        birthDate: String,
        gender: UserGender,
        role: UserRoleName
    ) {
        self.email = email
        self.phoneNumber = phoneNumber
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.gender = gender
        self.role = role
    }
}

// MARK: - Create from Register

extension UserCreateDTO {
    public init(from user: RegisterDTO) {
        self.email = user.email
        self.phoneNumber = user.phoneNumber
        self.password = user.password
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.birthDate = user.birthDate
        self.gender = user.gender
        self.role = UserRoleName.client
    }
}
