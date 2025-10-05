//
//  UserCreateDTOBuilder.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 06.09.2025.
//

@testable import Domain

final class UserCreateDTOBuilder {
    private var email = "builder@example.com"
    private var phoneNumber = "+1111111111"
    private var password = "pass1234"
    private var firstName = "Иван"
    private var lastName = "Иванов"
    private var birthDate = "2000-01-01 00:00:00"
    private var gender: UserGender = .male
    private var role: UserRoleName = .client

    func withEmail(_ email: String) -> Self { self.email = email; return self }
    func withPhoneNumber(_ phone: String) -> Self { self.phoneNumber = phone; return self }
    func withPassword(_ password: String) -> Self { self.password = password; return self }
    func withFirstName(_ firstName: String) -> Self { self.firstName = firstName; return self }
    func withLastName(_ lastName: String) -> Self { self.lastName = lastName; return self }
    func withBirthDate(_ date: String) -> Self { self.birthDate = date; return self }
    func withGender(_ gender: UserGender) -> Self { self.gender = gender; return self }
    func withRole(_ role: UserRoleName) -> Self { self.role = role; return self }

    func build() -> UserCreateDTO {
        UserCreateDTO(
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
