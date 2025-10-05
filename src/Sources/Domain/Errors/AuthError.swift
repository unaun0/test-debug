//
//  AuthError.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Vapor

public enum AuthError: Error {
    case missingToken
    case invalidToken
    case registerFailed
    case loginFailed
    case missingLogin
    case missingPassword
}

extension AuthError: AbortError {
    public var status: HTTPStatus {
        switch self {
        case .missingToken, .invalidToken:
            return .unauthorized
        case .missingLogin, .missingPassword:
            return .unauthorized
        case .registerFailed, .loginFailed:
            return .internalServerError

        }
    }

    public var reason: String {
        switch self {
        case .missingToken:
            return "Отсутствует или недействительный токен."
        case .invalidToken:
            return "Невалидный токен."
        case .registerFailed:
            return "Не удалось зарегестрировать пользователя."
        case .loginFailed:
            return "Не удалось войти в систему."
        case .missingLogin:
            return "Отсутсвует логин."
        case .missingPassword:
            return "Отсутствует пароль."
        }
    }
}
