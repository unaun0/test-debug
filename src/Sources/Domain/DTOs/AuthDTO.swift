//
//  Login.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Vapor

// MARK: - Login

public struct LoginDTO: Content {
    public let login: String
    public let password: String
}

// MARK: - Token

public struct TokenDTO: Content {
    public let token: String

    public init(token: String) {
        self.token = token
    }
}

// MARK: - Register

public struct RegisterDTO: Content {
    public let email: String
    public let phoneNumber: String
    public let password: String
    public let firstName: String
    public let lastName: String
    public let birthDate: String
    public let gender: UserGender

    public init(
        email: String,
        phoneNumber: String,
        password: String,
        firstName: String,
        lastName: String,
        birthDate: String,
        gender: UserGender
    ) {
        self.email = email
        self.phoneNumber = phoneNumber
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.gender = gender
    }
}
