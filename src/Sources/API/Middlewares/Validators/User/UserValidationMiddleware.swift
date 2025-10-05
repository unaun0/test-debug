//
//  UserUpdateValidationMiddleware.swift
//  Backend
//
//  Created by Цховребова Яна on 28.03.2025.
//

import Vapor
import Domain

public struct UserValidationMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        do {
            let json = try request.content.decode([String: String].self)
            if let email = json["email"], !UserValidator.validate(email: email) {
                throw UserError.invalidEmail
            }
            if let password = json["password"],
                !UserValidator.validate(password: password) {
                throw UserError.passwordTooWeak
            }
            if let phoneNumber = json["phoneNumber"],
                !UserValidator.validate(phoneNumber: phoneNumber) {
                throw UserError.invalidPhoneNumber
            }
            if let firstName = json["firstName"],
                !UserValidator.validate(name: firstName) {
                throw UserError.invalidFirstName
            }
            if let lastName = json["lastName"],
                !UserValidator.validate(name: lastName) {
                throw UserError.invalidLastName
            }
            if let gender = json["gender"],
                !UserValidator.validate(gender: gender) {
                throw UserError.invalidGender
            }
            if let birthDateString = json["birthDate"],
                !UserValidator.validate(date: birthDateString) {
                throw UserError.invalidBirthDate
            }
            if let role = json["role"] {
                guard UserValidator.validate(roleName: role)
                else { throw UserError.invalidRole }
            }
            return try await next.respond(to: request)
        } catch { throw error }
    }
}
