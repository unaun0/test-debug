//
//  UserUpdateDTOBuilder.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 06.09.2025.
//

@testable import Domain

final class UserUpdateDTOBuilder {
    private var email: String? = nil
    private var phoneNumber: String? = nil
    private var password: String? = nil
    private var firstName: String? = nil
    private var lastName: String? = nil
    private var birthDate: String? = nil
    private var gender: UserGender? = nil
    private var role: UserRoleName? = nil

    func withEmail(_ email: String) -> Self { self.email = email; return self }
    func withPhoneNumber(_ phone: String) -> Self { self.phoneNumber = phone; return self }
    func withPassword(_ password: String) -> Self { self.password = password; return self }
    func withFirstName(_ firstName: String) -> Self { self.firstName = firstName; return self }
    func withLastName(_ lastName: String) -> Self { self.lastName = lastName; return self }
    func withBirthDate(_ date: String) -> Self { self.birthDate = date; return self }
    func withGender(_ gender: UserGender) -> Self { self.gender = gender; return self }
    func withRole(_ role: UserRoleName) -> Self { self.role = role; return self }

    func build() -> UserUpdateDTO {
        UserUpdateDTO(
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
