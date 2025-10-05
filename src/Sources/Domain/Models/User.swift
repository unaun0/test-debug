//
//  User.swift
//  Backend
//
//  Created by Цховребова Яна on 10.03.2025.
//

import Vapor

// MARK: - UserRoleName

public enum UserRoleName: String {
    case client = "клиент"
    case trainer = "тренер"
    case admin = "администратор"
}

// MARK: - UserRoleName CaseIterable

extension UserRoleName: CaseIterable {}

// MARK: - UserRoleName Content

extension UserRoleName: Content {}

// MARK: - UserGender

public enum UserGender: String {
    case male = "мужской"
    case female = "женский"
}

// MARK: - UserGender CaseIterable

extension UserGender: CaseIterable {}

// MARK: - UserGender Content

extension UserGender: Content {}

// MARK: - User Model

public struct User: BaseModel {
    public var id: UUID
    public var email: String
    public var phoneNumber: String
    public var password: String
    public var firstName: String
    public var lastName: String
    public var birthDate: Date
    public var gender: UserGender
    public var role: UserRoleName

    public init(
        id: UUID = UUID(),
        email: String,
        phoneNumber: String,
        password: String,
        firstName: String,
        lastName: String,
        birthDate: Date,
        gender: UserGender,
        role: UserRoleName
    ) {
        self.id = id
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

// MARK: - User Equatable

extension User: Equatable {
    public static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
            && Calendar.current.isDate(
                lhs.birthDate, inSameDayAs: rhs.birthDate
            )
            && lhs.email == rhs.email
            && lhs.phoneNumber == rhs.phoneNumber
            && lhs.password == rhs.password
            && lhs.firstName == rhs.firstName
            && lhs.lastName == rhs.lastName
            && lhs.gender == rhs.gender
            && lhs.role == rhs.role
    }
}

// MARK: - User Sendable

extension User: @unchecked Sendable {}

// MARK: - User Authenticatable

extension User: Authenticatable {}
