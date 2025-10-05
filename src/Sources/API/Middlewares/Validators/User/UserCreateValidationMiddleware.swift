//
//  UserCreateValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 28.03.2025.
//

import Vapor
import Domain

public struct UserCreateValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        do {
            let json = try request.content.decode(
                [String: String].self
            )
            guard let email = json["email"],
                UserValidator.validate(email: email)
            else {
                throw UserError.invalidEmail
            }
            guard let password = json["password"],
                UserValidator.validate(password: password)
            else {
                throw UserError.passwordTooWeak
            }
            guard let phoneNumber = json["phoneNumber"],
                UserValidator.validate(phoneNumber: phoneNumber)
            else {
                throw UserError.invalidPhoneNumber
            }
            guard let firstName = json["firstName"],
                UserValidator.validate(name: firstName)
            else {
                throw UserError.invalidFirstName
            }
            guard let lastName = json["lastName"],
                UserValidator.validate(name: lastName)
            else {
                throw UserError.invalidLastName
            }
            guard let gender = json["gender"],
                UserValidator.validate(gender: gender)
            else {
                throw UserError.invalidGender
            }
            guard let birthDateString = json["birthDate"],
                UserValidator.validate(
                    date: birthDateString
                )
            else {
                throw UserError.invalidBirthDate
            }
            if let role = json["role"] {
                guard UserValidator.validate(roleName: role) else {
                    throw UserError.invalidRole
                }
            }
            return try await next.respond(to: request)
        } catch { throw error }
    }
}
