//
//  UserBuilder.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 03.09.2025.
//

import Vapor
@testable import Domain

final class UserBuilder {
    private var id = UUID()
    private var email = "builder@example.com"
    private var phoneNumber = "+1111111111"
    private var password = "pass1234"
    private var firstName = "Иван"
    private var lastName = "Иванов"
    private var birthDate = Date().yearsAgo(18)
    private var gender = UserGender.male
    private var role = UserRoleName.client

    func withId(_ id: UUID) -> Self { self.id = id; return self }
    func withEmail(_ email: String) -> Self { self.email = email; return self }
    func withPhoneNumber(_ phoneNumber: String) -> Self { self.phoneNumber = phoneNumber; return self }
    func withPassword(_ password: String) -> Self { self.password = password; return self }
    func withFirstName(_ firstName: String) -> Self { self.firstName = firstName; return self }
    func withLastName(_ lastName: String) -> Self { self.lastName = lastName; return self }
    func withBirthDate(_ birthDate: Date) -> Self { self.birthDate = birthDate; return self }
    func withAge(years: Int) -> Self { self.birthDate = Date().yearsAgo(years); return self }
    func withGender(_ gender: UserGender) -> Self { self.gender = gender; return self }
    func withRole(_ role: UserRoleName) -> Self { self.role = role; return self }

    func build() -> User {
        User(
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
