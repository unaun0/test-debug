//
//  UserEntity.swift
//  Backend
//
//  Created by Цховребова Яна on 11.04.2025.
//

import Fluent
import Vapor
import Domain

public final class UserDBDTO: Model {
    public static let schema = "User"

    @ID(custom: "id")
    public var id: UUID?

    @Field(key: "email")
    public var email: String

    @Field(key: "phone_number")
    public var phoneNumber: String

    @Field(key: "password")
    public var password: String

    @Field(key: "first_name")
    public var firstName: String

    @Field(key: "last_name")
    public var lastName: String

    @Field(key: "gender")
    public var gender: String

    @Field(key: "birth_date")
    public var birthDate: Date
    
    @Field(key: "role")
    public var role: String

    public init() {}
}

// MARK: - Convenience Initializator

extension UserDBDTO {
    public convenience init(
        id: UUID? = nil,
        email: String,
        phoneNumber: String,
        password: String,
        firstName: String,
        lastName: String,
        gender: String,
        birthDate: Date,
        role: String
    ) {
        self.init()

        self.id = id
        self.email = email
        self.phoneNumber = phoneNumber
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.gender = gender
        self.birthDate = birthDate
        self.role = role
    }
}

// MARK: - Sendable

extension UserDBDTO: @unchecked Sendable {}

// MARK: - Content

extension UserDBDTO: Content {}

// MARK: - From / To Model

extension UserDBDTO {
    public convenience init(from user: User) {
        self.init()

        self.id = user.id
        self.email = user.email
        self.phoneNumber = user.phoneNumber
        self.password = user.password
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.birthDate = user.birthDate
        self.gender = user.gender.rawValue
        self.role = user.role.rawValue
    }

    public func toUser() -> User? {
        guard
            let id = self.id,
            let gender = UserGender(rawValue: self.gender),
            let role = UserRoleName(rawValue: self.role)
        else { return nil }

        return User(
            id: id,
            email: email,
            phoneNumber: phoneNumber,
            password: password,
            firstName: firstName,
            lastName: lastName,
            birthDate: birthDate,
            gender: gender,
            role: role
        )
    }
}
