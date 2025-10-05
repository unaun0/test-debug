//
//  UserError.swift
//  Backend
//
//  Created by Цховребова Яна on 11.03.2025.
//

import Vapor

public enum UserError: Error {
    case userNotFound
    case creationFailed
    case updateFailed
    case deleteFailed
    case findFailed
    case invalidEmail
    case invalidPhoneNumber
    case invalidPassword
    case invalidName
    case invalidBirthDate
    case invalidGender
    case invalidData
    case invalidFirstName
    case invalidLastName
    case invalidUserId
    case passwordTooWeak
    case emailAlreadyExists
    case phoneNumberAlreadyExists
    case invalidEmailOrPhoneNumber
    case invalidRole
    case roleNotFound
    case permissionDenied
}

extension UserError: AbortError {
    public var status: HTTPStatus {
        switch self {
        case .userNotFound:
            return .badRequest
        case .creationFailed:
            return .internalServerError
        case .updateFailed:
            return .internalServerError
        case .deleteFailed:
            return .internalServerError
        case .findFailed:
            return .internalServerError
        case .invalidName:
            return .badRequest
        case .invalidEmail:
            return .badRequest
        case .invalidPhoneNumber:
            return .badRequest
        case .invalidPassword:
            return .badRequest
        case .invalidBirthDate:
            return .badRequest
        case .invalidGender:
            return .badRequest
        case .passwordTooWeak:
            return .badRequest
        case .invalidData:
            return .badRequest
        case .invalidFirstName:
            return .badRequest
        case .invalidLastName:
            return .badRequest
        case .invalidEmailOrPhoneNumber:
            return .badRequest
        case .invalidUserId:
            return .badRequest
        case .phoneNumberAlreadyExists:
            return .conflict
        case .emailAlreadyExists:
            return .conflict
        case .invalidRole:
            return .badRequest
        case .roleNotFound:
            return .badRequest
        case .permissionDenied:
            return .forbidden
        }
    }

    public var reason: String {
        switch self {
        case .userNotFound:
            return "Пользователь не найден."
        case .creationFailed:
            return "Не удалось создать пользователя."
        case .updateFailed:
            return "Не удалось обновить данные пользователя."
        case .findFailed:
            return "Не удалось найти пользователя."
        case .deleteFailed:
            return "Не удалось удалить пользователя."
        case .invalidEmail:
            return "Неверный формат email."
        case .invalidPhoneNumber:
            return "Неверный формат номера телефона."
        case .passwordTooWeak:
            return "Пароль слишком слабый."
        case .invalidPassword:
            return "Неверный пароль."
        case .invalidName:
            return "Неверное имя или фамилия."
        case .invalidFirstName:
            return "Неверное имя пользователя."
        case .invalidLastName:
            return "Неверная фамилия пользователя."
        case .invalidBirthDate:
            return "Неверная дата рождения (в пределах от 14 до 120 лет)."
        case .invalidGender:
            return "Неверный пол ('мужской' или 'женский')."
        case .emailAlreadyExists:
            return "Пользователь с указанным email уже существует."
        case .phoneNumberAlreadyExists:
            return "Пользователь с указанным номером телефона уже существует."
        case .invalidData:
            return "Ошибка валидации."
        case .invalidEmailOrPhoneNumber:
            return "Неверный номер телефона или email."
        case .invalidUserId:
            return "Неверный идентификатор пользователя."
        case .invalidRole:
            return "Неверная роль пользователя."
        case .roleNotFound:
            return "Роль пользователя не найдена."
        case .permissionDenied:
            return "Недостаточно прав."
        }
    }
}
