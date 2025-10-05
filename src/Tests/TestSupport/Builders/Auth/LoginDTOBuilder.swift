//
//  LoginDTOBuilder.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 07.09.2025.
//

import Foundation
@testable import Domain
import Vapor

final class LoginDTOBuilder {
    private var login: String = "user@example.com"
    private var password: String = "password123"

    func withLogin(_ login: String) -> Self { self.login = login; return self }
    func withPassword(_ password: String) -> Self { self.password = password; return self }

    func build() -> LoginDTO {
        return LoginDTO(login: login, password: password)
    }
}
