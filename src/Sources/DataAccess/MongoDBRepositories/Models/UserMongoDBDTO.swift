//
//  UserMongoDBDTO.swift
//  Backend
//
//  Created by Цховребова Яна on 29.05.2025.
//

import Fluent
import Vapor
import Domain

public final class UserMongoDBDTO: Model, @unchecked Sendable {
    public static let schema = "User"

    @ID(custom: "_id")
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

    public init(
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

extension UserMongoDBDTO {
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

