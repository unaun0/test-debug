//
//  MembershipTypeError.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Vapor

public enum MembershipTypeError: Error {
    case membershipTypeNotFound
    case invalidName
    case nameAlreadyExists
    case invalidPrice
    case invalidSessions
    case invalidDays
    case invalidCreation
    case invalidUpdate
}

extension MembershipTypeError: AbortError {
    public var status: HTTPStatus {
        switch self {
        case .membershipTypeNotFound:
            return .notFound
        case .invalidName:
            return .badRequest
        case .invalidPrice:
            return .badRequest
        case .invalidSessions:
            return .badRequest
        case .invalidDays:
            return .badRequest
        case .nameAlreadyExists:
            return .conflict
        case .invalidCreation, .invalidUpdate:
            return .badRequest
        }
    }

    public var reason: String {
        switch self {
        case .membershipTypeNotFound:
            return "Тип абонемента не найден."
        case .invalidName:
            return "Неверное имя типа абонемента."
        case .nameAlreadyExists:
            return "Тип абонемента с таким именем уже существует."
        case .invalidPrice:
            return "Цена абонемента не может быть отрицательной."
        case .invalidSessions:
            return "Количество занятий не может быть отрицательным."
        case .invalidDays:
            return
                "Количество дней действия абонемента не может быть отрицательным."
        case .invalidCreation:
            return "Ошибка при создании типа абонемента."
        case .invalidUpdate:
            return "Ошибка при обновлении типа абонемента."
        }
    }
}
