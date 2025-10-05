//
//  RegisterDTOBuilder.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 07.09.2025.
//

import Foundation
@testable import Domain
import Vapor

final class RegisterDTOBuilder {
    private var email: String = "user@example.com"
    private var phoneNumber: String = "+1111111111"
    private var password: String = "password123"
    private var firstName: String = "Иван"
    private var lastName: String = "Иванов"
    private var birthDate: String = "2000-01-01 00:00:00"
    private var gender: UserGender = .male

    func withEmail(_ email: String) -> Self { self.email = email; return self }
    func withPhoneNumber(_ phone: String) -> Self { self.phoneNumber = phone; return self }
    func withPassword(_ password: String) -> Self { self.password = password; return self }
    func withFirstName(_ firstName: String) -> Self { self.firstName = firstName; return self }
    func withLastName(_ lastName: String) -> Self { self.lastName = lastName; return self }
    func withBirthDate(_ date: String) -> Self { self.birthDate = date; return self }
    func withGender(_ gender: UserGender) -> Self { self.gender = gender; return self }

    func build() -> RegisterDTO {
        return RegisterDTO(
            email: email,
            phoneNumber: phoneNumber,
            password: password,
            firstName: firstName,
            lastName: lastName,
            birthDate: birthDate,
            gender: gender
        )
    }
}
